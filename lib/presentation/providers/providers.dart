import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'dart:io'; // for Platform

import '../../data/database/database.dart';
import '../../domain/usecases/calculate_rest_days.dart';
import '../../domain/usecases/calculate_frequency.dart';
import '../../domain/usecases/calculate_training_points.dart';
import '../../data/services/export_service.dart';
import '../../data/services/backup_service.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../data/cloud/auth_service.dart';
import '../../data/cloud/sync_service_impl.dart';
import '../../data/cloud/providers/auth_state.dart' as app_auth;
import '../../data/cloud/providers/sync_state.dart';
import 'settings_storage.dart';

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// UseCase Providers
final calculateRestDaysProvider = Provider<CalculateRestDaysUseCase>((ref) {
  return CalculateRestDaysUseCase(ref.watch(databaseProvider));
});

final calculateFrequencyProvider = Provider<CalculateFrequencyUseCase>((ref) {
  return CalculateFrequencyUseCase(ref.watch(databaseProvider));
});

// Training Points (TP) calculation provider for heatmap
final calculateTrainingPointsProvider = Provider<CalculateTrainingPointsUseCase>((ref) {
  return CalculateTrainingPointsUseCase(ref.watch(databaseProvider));
});

// Service Providers
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(ref.watch(databaseProvider));
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

// Repository Providers
final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository(ref.watch(databaseProvider));
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(databaseProvider));
});

// Stream Providers
final bodyPartsProvider = StreamProvider<List<BodyPart>>((ref) {
  return ref.watch(databaseProvider).watchAllBodyParts();
});

final exercisesProvider = StreamProvider<List<Exercise>>((ref) {
  return ref.watch(databaseProvider).watchAllExercises();
});

final sessionsProvider = StreamProvider<List<WorkoutSession>>((ref) {
  return ref.watch(databaseProvider).watchAllSessions();
});

// Sessions indexed by date for O(1) lookup in calendar
final sessionsByDateProvider = Provider<Map<DateTime, List<WorkoutSession>>>((ref) {
  final sessionsAsync = ref.watch(sessionsProvider);
  
  return sessionsAsync.when(
    data: (sessions) {
      final Map<DateTime, List<WorkoutSession>> index = {};
      for (final session in sessions) {
        final date = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );
        index.putIfAbsent(date, () => []).add(session);
      }
      return index;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// Today's trained body parts - for Plan completion status
final todayTrainedBodyPartsProvider = FutureProvider<Set<String>>((ref) async {
  // Watch sessions to rebuild when sessions change
  ref.watch(sessionsProvider);
  
  final db = ref.watch(databaseProvider);
  
  // Get today's date range
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  // Get sessions for today
  final todaySessions = await db.getSessionsInDateRange(startOfDay, endOfDay);
  
  if (todaySessions.isEmpty) {
    return {};
  }
  
  // Collect all body part IDs from today's exercise records
  // (not from session.bodyPartIds which is always empty)
  final Set<String> bodyPartIds = {};
  
  for (final session in todaySessions) {
    // Get exercise records for this session
    final records = await db.getRecordsBySession(session.id);
    
    for (final record in records) {
      // Get the exercise to find its body parts
      final exercise = await db.getExerciseById(record.exerciseId ?? '');
      if (exercise != null) {
        // Parse bodyPartIds from the exercise
        final bpIds = db.parseBodyPartIds(exercise.bodyPartIds);
        bodyPartIds.addAll(bpIds);
      }
    }
  }
  
  return bodyPartIds;
});

// Today's trained muscle groups - for Plan completion status (by name matching)
final todayTrainedMuscleGroupsProvider = FutureProvider<Set<String>>((ref) async {
  // Watch sessions to rebuild when sessions change
  ref.watch(sessionsProvider);
  
  final db = ref.watch(databaseProvider);
  
  // Get today's date range
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  // Get sessions for today
  final todaySessions = await db.getSessionsInDateRange(startOfDay, endOfDay);
  
  if (todaySessions.isEmpty) {
    return {};
  }
  
  // Get all body parts to map IDs to names
  final allBodyParts = await db.getAllBodyParts();
  final bodyPartIdToName = {for (var bp in allBodyParts) bp.id: bp.name.toLowerCase()};
  
  // Collect all body part names from today's exercise records
  final Set<String> bodyPartNames = {};
  
  for (final session in todaySessions) {
    try {
      // Get exercise records for this session
      final records = await db.getRecordsBySession(session.id);
      
      for (final record in records) {
        // Skip if exerciseId is null or empty
        if (record.exerciseId == null || record.exerciseId!.isEmpty) continue;
        
        try {
          // Get the exercise to find its body parts
          final exercise = await db.getExerciseById(record.exerciseId!);
          if (exercise != null) {
            // Parse bodyPartIds from the exercise - using database method
            final bpIds = db.parseBodyPartIds(exercise.bodyPartIds);
            for (final bpId in bpIds) {
              final name = bodyPartIdToName[bpId];
              if (name != null && name.isNotEmpty) {
                bodyPartNames.add(name.toLowerCase());
              }
            }
          }
        } catch (e) {
          // Continue to next record if there's an error
          continue;
        }
      }
    } catch (e) {
      // Continue to next session if there's an error
      continue;
    }
  }
  
  return bodyPartNames;
});

// Uncompleted items count for active plan - for badge display
final uncompletedItemsCountProvider = FutureProvider<int>((ref) async {
  // Watch sessions to rebuild when sessions change
  ref.watch(sessionsProvider);
  
  // Check if there's an active preset plan
  final activePresetPlan = ref.watch(activePresetPlanProvider);
  
  // Check if there's an active custom plan
  final activePlanAsync = ref.watch(activePlanProvider);
  final activeCustomPlan = activePlanAsync.when(
    data: (plan) => plan,
    loading: () => null,
    error: (_, __) => null,
  );
  
  // Get today's trained muscle groups
  final todayMusclesAsync = ref.watch(todayTrainedMuscleGroupsProvider);
  
  final todayMuscles = todayMusclesAsync.when(
    data: (muscles) => muscles,
    loading: () => <String>{},
    error: (_, __) => <String>{},
  );
  
  // If no plan is active, return 0
  if (activePresetPlan == null && activeCustomPlan == null) {
    return 0;
  }
  
  // Get today's day of week (1=Monday, 7=Sunday)
  final todayWeekday = DateTime.now().weekday;
  
  // Get the schedule based on which plan is active
  Map<int, List<String>>? schedule;
  List<String>? customBodyPartIds;
  
  if (activePresetPlan != null) {
    // Use preset plan schedule
    final presetSchedule = _getPresetSchedule(activePresetPlan);
    if (presetSchedule != null) {
      schedule = presetSchedule;
    }
  } else if (activeCustomPlan != null) {
    // Use custom plan items
    final db = ref.watch(databaseProvider);
    final planItems = await db.getPlanItemsByPlan(activeCustomPlan.id);
    final currentDay = activeCustomPlan.currentDayIndex ?? 1;
    
    // Find the plan item for current day
    final currentDayIndex = currentDay - 1; // Convert 1-based to 0-based
    final currentItem = planItems.where((item) => item.dayIndex == currentDayIndex).firstOrNull;
    
    if (currentItem != null) {
      customBodyPartIds = currentItem.bodyPartIds.split(',').where((s) => s.isNotEmpty).toList();
    }
  }

  if (schedule == null && customBodyPartIds == null) {
    return 0;
  }

  // Calculate uncompleted count
  int uncompletedCount = 0;

  if (schedule != null) {
    // Preset plan: check muscle groups in schedule for today
    final dayMuscles = schedule[todayWeekday];
    if (dayMuscles != null) {
      for (final muscleName in dayMuscles) {
        if (muscleName.toLowerCase() == 'rest') continue;
        
        // Check if this muscle was trained today
        bool found = false;
        for (final trained in todayMuscles) {
          if (trained.contains(muscleName.toLowerCase()) || muscleName.toLowerCase().contains(trained)) {
            found = true;
            break;
          }
        }
        if (!found) {
          uncompletedCount++;
        }
      }
    }
  } else if (customBodyPartIds != null) {
    // Custom plan: check body part IDs
    final db = ref.watch(databaseProvider);
    final allBodyParts = await db.getAllBodyParts();
    
    for (final bpId in customBodyPartIds) {
      final bodyPart = allBodyParts.where((bp) => bp.id == bpId).firstOrNull;
      if (bodyPart != null) {
        final bpNameLower = bodyPart.name.toLowerCase();
        bool found = false;
        for (final trained in todayMuscles) {
          if (trained.contains(bpNameLower) || bpNameLower.contains(trained)) {
            found = true;
            break;
          }
        }
        if (!found) {
          uncompletedCount++;
        }
      }
    }
  }
  
  return uncompletedCount;
});

// Helper function to get preset plan schedule
Map<int, List<String>>? _getPresetSchedule(String planName) {
  // Import the WorkoutTemplates
  // This is a workaround since we can't import directly in provider
  switch (planName) {
    case 'PPL':
      return {
        1: ['chest', 'shoulders', 'arms'],
        2: ['back', 'arms'],
        3: ['legs'],
        4: ['rest'],
        5: ['chest', 'shoulders', 'arms'],
        6: ['back', 'arms'],
        7: ['legs'],
      };
    case 'Upper/Lower':
      return {
        1: ['chest', 'back', 'shoulders', 'arms'],
        2: ['legs'],
        3: ['rest'],
        4: ['chest', 'back', 'shoulders', 'arms'],
        5: ['legs'],
        6: ['rest'],
        7: ['rest'],
      };
    case 'Bro Split':
      return {
        1: ['chest'],
        2: ['back'],
        3: ['legs'],
        4: ['shoulders'],
        5: ['arms'],
        6: ['rest'],
        7: ['rest'],
      };
    default:
      return null;
  }
}

// Training Points (TP) indexed by date for heatmap visualization
final trainingPointsByDateProvider = FutureProvider<Map<DateTime, double>>((ref) async {
  final sessionsAsync = ref.watch(sessionsProvider);
  final tpUseCase = ref.watch(calculateTrainingPointsProvider);
  
  return sessionsAsync.when(
    data: (sessions) async {
      final Map<DateTime, double> index = {};
      for (final session in sessions) {
        final date = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );
        final tp = await tpUseCase.calculateSessionTP(session.id);
        // Accumulate TP for days with multiple sessions
        index[date] = (index[date] ?? 0) + tp;
      }
      return index;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// Maximum TP value for normalization (used for color mapping)
final maxTrainingPointsProvider = Provider<double>((ref) {
  final tpAsync = ref.watch(trainingPointsByDateProvider);
  
  return tpAsync.when(
    data: (tpMap) {
      if (tpMap.isEmpty) return 100.0; // Default fallback
      return tpMap.values.reduce((a, b) => a > b ? a : b);
    },
    loading: () => 100.0,
    error: (_, __) => 100.0,
  );
});

final plansProvider = StreamProvider<List<TrainingPlan>>((ref) {
  return ref.watch(databaseProvider).watchAllPlans();
});

// Plan-specific providers
final customPlanByNameProvider = Provider.family<TrainingPlan?, String>((ref, planName) {
  final plansAsync = ref.watch(plansProvider);
  return plansAsync.when(
    data: (plans) {
      try {
        return plans.firstWhere((p) => p.name == planName);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Global provider for plan items that can be invalidated from anywhere
final planItemsProvider = FutureProvider.family<List<PlanItem>, String>((ref, planId) async {
  final repo = ref.watch(planRepositoryProvider);
  return repo.getPlanItemsByPlan(planId);
});

// Settings Providers - Use Flutter's ThemeMode with SharedPreferences persistence

/// ThemeMode StateNotifier with persistence
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(SettingsStorage.getThemeMode());

  void setThemeMode(ThemeMode mode) {
    state = mode;
    SettingsStorage.setThemeMode(mode);
  }
}

/// Locale StateNotifier with persistence
class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super(SettingsStorage.getLocale());

  void setLocale(String locale) {
    state = locale;
    SettingsStorage.setLocale(locale);
  }
}

// Providers for theme mode and locale
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

// Plan Page State
// Default plan name provider - returns currently executing plan or first preset
final defaultPlanNameProvider = Provider<String>((ref) {
  // Check if there's an executing custom plan
  final activePlanAsync = ref.watch(activePlanProvider);
  final activeCustomPlan = activePlanAsync.when(
    data: (plan) => plan?.name,
    loading: () => null,
    error: (_, __) => null,
  );
  if (activeCustomPlan != null) return activeCustomPlan;

  // Check if there's an executing preset plan
  final activePreset = ref.watch(activePresetPlanProvider);
  if (activePreset != null) return activePreset;

  // Default to first preset plan
  return 'PPL';
});

final selectedPlanProvider = StateProvider<String>((ref) {
  return ref.watch(defaultPlanNameProvider);
});

// Active (executing) plan provider
final activePlanProvider = FutureProvider<TrainingPlan?>((ref) async {
  final repo = ref.watch(planRepositoryProvider);
  return repo.getActivePlan();
});

// Active preset plan name (for preset plans like PPL)
final activePresetPlanProvider = StateProvider<String?>((ref) {
  return SettingsStorage.getActivePresetPlan();
});

// Active preset plan day index
final activePresetDayIndexProvider = StateProvider<int>((ref) {
  return SettingsStorage.getActivePresetDayIndex();
});

// Current provider training day index
final currentTrainingDayProvider = Provider<int>((ref) {
  // Check custom plan first
  final activePlanAsync = ref.watch(activePlanProvider);
  final customDay = activePlanAsync.when(
    data: (plan) => plan?.currentDayIndex,
    loading: () => null,
    error: (_, __) => null,
  );
  if (customDay != null) return customDay;

  // Then check preset plan
  return ref.watch(activePresetDayIndexProvider);
});

// Check if a plan is currently executing
final isPlanExecutingProvider = Provider.family<bool, String>((ref, planName) {
  // Check custom plans
  final activePlanAsync = ref.watch(activePlanProvider);
  final isCustomExecuting = activePlanAsync.when(
    data: (plan) => plan?.name == planName,
    loading: () => false,
    error: (_, __) => false,
  );
  if (isCustomExecuting) return true;

  // Check preset plans
  final activePreset = ref.watch(activePresetPlanProvider);
  return activePreset == planName;
});

// ============ Cloud Sync Providers ============

// Note: These providers require configuration with actual ClientID and Secret
// They are placeholders that need to be initialized with real credentials

/// Cloud client configuration
/// Reads credentials from environment variables.
/// Priority:
/// 1. --dart-define (String.fromEnvironment) - Works everywhere, recommended for CI/CD & Mobile
/// 2. Platform.environment - Works only on Desktop runtimes (Windows/macOS/Linux) for local dev convenience
class CloudConfig {
  // Use --dart-define=SUPABASE_URL=your_url
  static String get supabaseUrl {
    const fromEnv = String.fromEnvironment('SUPABASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    
    // Fallback to system environment variables (Desktop only)
    try {
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        return Platform.environment['SUPABASE_URL'] ?? '';
      }
    } catch (_) {
      // Ignore platform errors on unsupported platforms
    }
    
    return '';
  }
  
  // Use --dart-define=SUPABASE_ANON_KEY=your_key
  static String get supabaseAnonKey {
    const fromEnv = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    
    // Fallback to system environment variables (Desktop only)
    try {
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        return Platform.environment['SUPABASE_ANON_KEY'] ?? '';
      }
    } catch (_) {
      // Ignore platform errors
    }
    
    return '';
  }

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

/// Supabase Client Provider
/// Returns the Supabase client (always initialized in main.dart)
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

/// Auth State Provider
final authStateProvider = StateNotifierProvider<app_auth.AuthStateNotifier, app_auth.AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return app_auth.AuthStateNotifier(authService);
});

/// Cloud Sync Service Provider
final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService(
    ref.watch(supabaseClientProvider),
    ref.watch(databaseProvider),
  );
});

/// Sync State Provider
final syncStateProvider = StateNotifierProvider<SyncStateNotifier, SyncState>((ref) {
  return SyncStateNotifier(ref.watch(cloudSyncServiceProvider));
});

// ============ Heatmap Providers ============

/// Heatmap time range enum
enum HeatmapTimeRange { last7Days, last30Days }

/// Heatmap time range state provider
final heatmapTimeRangeProvider = StateProvider<HeatmapTimeRange>((ref) {
  return HeatmapTimeRange.last7Days;
});

/// Training Points (TP) for heatmap by date in a specific range
final trainingPointsInRangeProvider = FutureProvider.family<Map<DateTime, double>, HeatmapTimeRange>((ref, timeRange) async {
  final sessionsAsync = ref.watch(sessionsProvider);
  final tpUseCase = ref.watch(calculateTrainingPointsProvider);
  
  return sessionsAsync.when(
    data: (sessions) async {
      final now = DateTime.now();
      final startDate = timeRange == HeatmapTimeRange.last7Days 
          ? now.subtract(const Duration(days: 6))
          : now.subtract(const Duration(days: 29));
      
      // Normalize to start of day
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(now.year, now.month, now.day);
      
      final Map<DateTime, double> index = {};
      
      for (final session in sessions) {
        final sessionDate = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );
        
        // Only include sessions within range
        if (sessionDate.isBefore(start) || sessionDate.isAfter(end)) {
          continue;
        }
        
        final tp = await tpUseCase.calculateSessionTP(session.id);
        index[sessionDate] = (index[sessionDate] ?? 0) + tp;
      }
      
      return index;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Maximum TP value for heatmap in current range
final maxTrainingPointsInRangeProvider = Provider.family<double, HeatmapTimeRange>((ref, timeRange) {
  final tpAsync = ref.watch(trainingPointsInRangeProvider(timeRange));
  
  return tpAsync.when(
    data: (tpMap) {
      if (tpMap.isEmpty) return 100.0;
      return tpMap.values.reduce((a, b) => a > b ? a : b);
    },
    loading: () => 100.0,
    error: (_, __) => 100.0,
  );
});