import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/database/database.dart';
import 'presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ignore SSL certificate errors in debug mode
  if (kDebugMode) {
    HttpOverrides.global = _MyHttpOverrides();
  }

  // Initialize Supabase
  if (CloudConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: CloudConfig.supabaseUrl,
        anonKey: CloudConfig.supabaseAnonKey,
      );
      debugPrint('[DEBUG] Supabase initialized successfully');
    } catch (e) {
      debugPrint('[DEBUG] Supabase initialization failed: $e');
    }
  } else {
    debugPrint('[DEBUG] Supabase configuration missing, skipping initialization');
  }
  
  debugPrint('[DEBUG] Starting app initialization...');
  
  // Initialize default body parts
  await _initializeDefaultBodyParts();
  
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
      bodyPartId: 'body_chest',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_incline_press',
      name: 'Incline Press',
      bodyPartId: 'body_chest',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_push_up',
      name: 'Push Up',
      bodyPartId: 'body_chest',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_cable_fly',
      name: 'Cable Fly',
      bodyPartId: 'body_chest',
      createdAt: DateTime.now().toUtc(),
    ),
    // Back exercises
    ExercisesCompanion.insert(
      id: 'ex_deadlift',
      name: 'Deadlift',
      bodyPartId: 'body_back',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_lat_pulldown',
      name: 'Lat Pulldown',
      bodyPartId: 'body_back',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_barbell_row',
      name: 'Barbell Row',
      bodyPartId: 'body_back',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_pull_up',
      name: 'Pull Up',
      bodyPartId: 'body_back',
      createdAt: DateTime.now().toUtc(),
    ),
    // Legs exercises
    ExercisesCompanion.insert(
      id: 'ex_squat',
      name: 'Squat',
      bodyPartId: 'body_legs',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_leg_press',
      name: 'Leg Press',
      bodyPartId: 'body_legs',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_lunge',
      name: 'Lunge',
      bodyPartId: 'body_legs',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_leg_curl',
      name: 'Leg Curl',
      bodyPartId: 'body_legs',
      createdAt: DateTime.now().toUtc(),
    ),
    // Shoulders exercises
    ExercisesCompanion.insert(
      id: 'ex_overhead_press',
      name: 'Overhead Press',
      bodyPartId: 'body_shoulders',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_lateral_raise',
      name: 'Lateral Raise',
      bodyPartId: 'body_shoulders',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_front_raise',
      name: 'Front Raise',
      bodyPartId: 'body_shoulders',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_face_pull',
      name: 'Face Pull',
      bodyPartId: 'body_shoulders',
      createdAt: DateTime.now().toUtc(),
    ),
    // Arms exercises
    ExercisesCompanion.insert(
      id: 'ex_bicep_curl',
      name: 'Bicep Curl',
      bodyPartId: 'body_arms',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_tricep_pushdown',
      name: 'Tricep Pushdown',
      bodyPartId: 'body_arms',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_hammer_curl',
      name: 'Hammer Curl',
      bodyPartId: 'body_arms',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_tricep_extension',
      name: 'Tricep Extension',
      bodyPartId: 'body_arms',
      createdAt: DateTime.now().toUtc(),
    ),
    // Glutes exercises
    ExercisesCompanion.insert(
      id: 'ex_hip_thrust',
      name: 'Hip Thrust',
      bodyPartId: 'body_glutes',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_glute_bridge',
      name: 'Glute Bridge',
      bodyPartId: 'body_glutes',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_cable_kickback',
      name: 'Cable Kickback',
      bodyPartId: 'body_glutes',
      createdAt: DateTime.now().toUtc(),
    ),
    // Abs exercises
    ExercisesCompanion.insert(
      id: 'ex_crunch',
      name: 'Crunch',
      bodyPartId: 'body_abs',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_plank',
      name: 'Plank',
      bodyPartId: 'body_abs',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_leg_raise',
      name: 'Leg Raise',
      bodyPartId: 'body_abs',
      createdAt: DateTime.now().toUtc(),
    ),
    ExercisesCompanion.insert(
      id: 'ex_russian_twist',
      name: 'Russian Twist',
      bodyPartId: 'body_abs',
      createdAt: DateTime.now().toUtc(),
    ),
  ];
  
  for (final exercise in defaultExercises) {
    await db.insertExercise(exercise);
  }
}
