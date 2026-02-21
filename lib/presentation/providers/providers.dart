import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'dart:io'; // for Platform

import '../../data/database/database.dart';
import '../../domain/usecases/calculate_rest_days.dart';
import '../../domain/usecases/calculate_frequency.dart';
import '../../data/services/export_service.dart';
import '../../data/services/backup_service.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../data/cloud/auth_service.dart';
import '../../data/cloud/sync_service_impl.dart';
import '../../data/cloud/providers/auth_state.dart' as app_auth;
import '../../data/cloud/providers/sync_state.dart';

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

// Note: CalculateVolumeUseCase is defined in calculate_volume.dart
// but not currently used by any page. Uncomment below if needed:
// final calculateVolumeProvider = Provider<CalculateVolumeUseCase>((ref) {
//   return CalculateVolumeUseCase(ref.watch(databaseProvider));
// });

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

// Settings Providers - Use Flutter's ThemeMode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<String>((ref) => 'en');

// Plan Page State
final selectedPlanProvider = StateProvider<String>((ref) => 'PPL');

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
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

/// Auth State Provider
final authStateProvider = StateNotifierProvider<app_auth.AuthStateNotifier, app_auth.AuthState>((ref) {
  return app_auth.AuthStateNotifier(ref.watch(authServiceProvider));
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