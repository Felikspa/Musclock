import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/database.dart';
import '../../domain/usecases/calculate_rest_days.dart';
import '../../domain/usecases/calculate_frequency.dart';
// import '../../domain/usecases/calculate_volume.dart'; // Not currently used
import '../../data/services/export_service.dart';
import '../../data/services/backup_service.dart';

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

final plansProvider = StreamProvider<List<TrainingPlan>>((ref) {
  return ref.watch(databaseProvider).watchAllPlans();
});

// Settings Providers - Use Flutter's ThemeMode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final localeProvider = StateProvider<String>((ref) => 'en');
