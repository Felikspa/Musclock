import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/database/database.dart';
import 'presentation/providers/providers.dart';
import 'presentation/providers/settings_storage.dart';
import 'core/constants/muscle_groups.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings storage (SharedPreferences)
  await SettingsStorage.init();

  // Ignore SSL certificate errors in debug mode
  if (kDebugMode) {
    HttpOverrides.global = _MyHttpOverrides();
  }

  // Initialize Supabase (even if not configured, to prevent crashes when accessing Supabase.instance)
  // When not configured, use placeholder values that will fail gracefully
  try {
    final url = CloudConfig.supabaseUrl.isNotEmpty
        ? CloudConfig.supabaseUrl
        : 'https://placeholder.supabase.co';
    final key = CloudConfig.supabaseAnonKey.isNotEmpty
        ? CloudConfig.supabaseAnonKey
        : 'placeholder';

    await Supabase.initialize(
      url: url,
      anonKey: key,
    );
    debugPrint('[DEBUG] Supabase initialized successfully');
  } catch (e) {
    debugPrint('[DEBUG] Supabase initialization failed: $e');
  }

  debugPrint('[DEBUG] Starting app initialization...');

  // Initialize default body parts
  await _initializeDefaultBodyParts();

  // Auto-update training day for active plans
  await _updateTrainingDayOnStartup();

  runApp(
    const ProviderScope(
      child: MuscleClockApp(),
    ),
  );
}

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> _initializeDefaultBodyParts() async {
  final db = AppDatabase();
  
  // Check if body parts already exist
  final existingParts = await db.getAllBodyParts();
  if (existingParts.isNotEmpty) {
    return; // Already initialized
  }
  
  // Add default body parts
  final defaultBodyParts = [
    BodyPartsCompanion.insert(
      id: 'body_chest',
      name: 'Chest',
      createdAt: DateTime.now().toUtc(),
    ),
    BodyPartsCompanion.insert(
      id: 'body_back',
      name: 'Back',
      createdAt: DateTime.now().toUtc(),
    ),
    BodyPartsCompanion.insert(
      id: 'body_legs',
      name: 'Legs',
      createdAt: DateTime.now().toUtc(),
    ),
    BodyPartsCompanion.insert(
      id: 'body_shoulders',
      name: 'Shoulders',
      createdAt: DateTime.now().toUtc(),
    ),
    BodyPartsCompanion.insert(
      id: 'body_arms',
      name: 'Arms',
      createdAt: DateTime.now().toUtc(),
    ),
    BodyPartsCompanion.insert(
      id: 'body_glutes',
      name: 'Glutes',
      createdAt: DateTime.now().toUtc(),
    ),
    BodyPartsCompanion.insert(
      id: 'body_abs',
      name: 'Abs',
      createdAt: DateTime.now().toUtc(),
    ),
  ];
  
  for (final part in defaultBodyParts) {
    await db.insertBodyPart(part);
  }
  
  // Initialize default exercises
  await _initializeDefaultExercises(db);
}

Future<void> _initializeDefaultExercises(AppDatabase db) async {
  // Check if exercises already exist
  final existingExercises = await db.getAllExercises();
  if (existingExercises.isNotEmpty) {
    return; // Already initialized
  }
  
  // Default exercises for each body part
  final defaultExercises = [
    // Chest exercises
    ExercisesCompanion.insert(
      id: 'ex_bench_press',
      name: 'Bench Press',
      bodyPartIds: Value('["body_chest"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_incline_press',
      name: 'Incline Press',
      bodyPartIds: Value('["body_chest"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_push_up',
      name: 'Push Up',
      bodyPartIds: Value('["body_chest"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_cable_fly',
      name: 'Cable Fly',
      bodyPartIds: Value('["body_chest"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    // Back exercises
    ExercisesCompanion.insert(
      id: 'ex_deadlift',
      name: 'Deadlift',
      bodyPartIds: Value('["body_back", "body_glutes", "body_legs"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_lat_pulldown',
      name: 'Lat Pulldown',
      bodyPartIds: Value('["body_back"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_barbell_row',
      name: 'Barbell Row',
      bodyPartIds: Value('["body_back"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_pull_up',
      name: 'Pull Up',
      bodyPartIds: Value('["body_back"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    // Legs exercises
    ExercisesCompanion.insert(
      id: 'ex_squat',
      name: 'Squat',
      bodyPartIds: Value('["body_legs", "body_glutes"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_leg_press',
      name: 'Leg Press',
      bodyPartIds: Value('["body_legs"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_lunge',
      name: 'Lunge',
      bodyPartIds: Value('["body_legs"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_leg_curl',
      name: 'Leg Curl',
      bodyPartIds: Value('["body_legs"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    // Shoulders exercises
    ExercisesCompanion.insert(
      id: 'ex_overhead_press',
      name: 'Overhead Press',
      bodyPartIds: Value('["body_shoulders"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_lateral_raise',
      name: 'Lateral Raise',
      bodyPartIds: Value('["body_shoulders"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_front_raise',
      name: 'Front Raise',
      bodyPartIds: Value('["body_shoulders"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_face_pull',
      name: 'Face Pull',
      bodyPartIds: Value('["body_shoulders"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    // Arms exercises
    ExercisesCompanion.insert(
      id: 'ex_bicep_curl',
      name: 'Bicep Curl',
      bodyPartIds: Value('["body_arms"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_tricep_pushdown',
      name: 'Tricep Pushdown',
      bodyPartIds: Value('["body_arms"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_hammer_curl',
      name: 'Hammer Curl',
      bodyPartIds: Value('["body_arms"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_tricep_extension',
      name: 'Tricep Extension',
      bodyPartIds: Value('["body_arms"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    // Glutes exercises
    ExercisesCompanion.insert(
      id: 'ex_hip_thrust',
      name: 'Hip Thrust',
      bodyPartIds: Value('["body_glutes"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_glute_bridge',
      name: 'Glute Bridge',
      bodyPartIds: Value('["body_glutes"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_cable_kickback',
      name: 'Cable Kickback',
      bodyPartIds: Value('["body_glutes"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    // Abs exercises
    ExercisesCompanion.insert(
      id: 'ex_crunch',
      name: 'Crunch',
      bodyPartIds: Value('["body_abs"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_plank',
      name: 'Plank',
      bodyPartIds: Value('["body_abs"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_leg_raise',
      name: 'Leg Raise',
      bodyPartIds: Value('["body_abs"]'),
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_russian_twist',
      name: 'Russian Twist',
      bodyPartIds: Value('["body_abs"]'),
      createdAt: DateTime.now().toUtc(),
    ),
  ];
  
  for (final exercise in defaultExercises) {
    await db.insertExercise(exercise);
  }
}

/// Auto-update training day for active plans on app startup
/// This calculates the current day based on the start date and cycles if needed
Future<void> _updateTrainingDayOnStartup() async {
  final db = AppDatabase();

  // Check for active custom plan
  final activePlan = await db.getActivePlan();
  if (activePlan != null && activePlan.startDate != null) {
    final startDate = activePlan.startDate!;
    final now = DateTime.now().toUtc();
    final daysPassed = now.difference(startDate).inDays;

    if (daysPassed > 0) {
      // Calculate new day index (cycle if needed)
      int newDayIndex = activePlan.currentDayIndex ?? 1;
      newDayIndex = ((newDayIndex - 1 + daysPassed) % activePlan.cycleLengthDays) + 1;

      // Update the day index
      await db.updateActivePlanDayIndex(newDayIndex);
      debugPrint('[DEBUG] Auto-updated custom plan "$activePlan" to Day $newDayIndex');
    }
  }

  // Check for active preset plan in settings
  final activePresetPlan = SettingsStorage.getActivePresetPlan();
  if (activePresetPlan != null) {
    final dayIndex = SettingsStorage.getActivePresetDayIndex();

    // Get the schedule length for this preset plan
    final schedule = WorkoutTemplates.getSchedule(activePresetPlan);
    if (schedule != null) {
      // For simplicity, we store the last active day in settings
      // In a more complete implementation, we'd also store the start date
      // Here we just keep the current day - the user can manually advance it
      debugPrint('[DEBUG] Active preset plan: $activePresetPlan, Day $dayIndex');
    }
  }
}
