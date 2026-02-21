import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../domain/usecases/calculate_rest_days.dart';
import '../../domain/usecases/calculate_frequency.dart';
// import '../../domain/usecases/calculate_volume.dart'; // Not currently used
import '../../data/services/export_service.dart';
import '../../data/services/backup_service.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../domain/repositories/session_repository.dart';

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

// Settings Providers - Use Flutter's ThemeMode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<String>((ref) => 'en');

// Plan Page State
final selectedPlanProvider = StateProvider<String>((ref) => 'PPL');