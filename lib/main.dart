import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'app.dart';
import 'data/database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('[DEBUG] Starting app initialization...');
  
  // Initialize default body parts
  await _initializeDefaultBodyParts();
  
  debugPrint('[DEBUG] Database initialization complete, starting app...');
  
  runApp(
    const ProviderScope(
      child: MuscleClockApp(),
    ),
  );
}

Future<void> _initializeDefaultBodyParts() async {
  debugPrint('[DEBUG] Creating database instance...');
  final db = AppDatabase();
  
  debugPrint('[DEBUG] Checking existing body parts...');
  
  // Define all body parts that should exist
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
      id: 'body_glutes',
      name: 'Glutes',
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
      id: 'body_abs',
      name: 'Abs',
      createdAt: DateTime.now().toUtc(),
    ),
  ];
  
  // Check and add each body part if it doesn't exist
  for (final part in defaultBodyParts) {
    final existing = await db.getBodyPartById(part.id.value);
    if (existing == null) {
      debugPrint('[DEBUG] Adding body part: ${part.name.value}');
      await db.insertBodyPart(part);
    }
  }
  
  // Check if exercises exist, if not add them
  final existingParts = await db.getAllBodyParts();
  if (existingParts.isNotEmpty) {
    final allExercises = await db.getAllExercises();
    if (allExercises.isEmpty) {
      debugPrint('[DEBUG] No exercises found, adding preset exercises...');
      await _initializeDefaultExercises(db);
    }
    return; // Body parts already exist, no need to reinitialize
  }
  
  debugPrint('[DEBUG] Inserting default body parts...');
  
  for (final part in defaultBodyParts) {
    await db.insertBodyPart(part);
  }
  
  // Add preset exercises for each body part
  await _initializeDefaultExercises(db);
}

Future<void> _initializeDefaultExercises(AppDatabase db) async {
  debugPrint('[DEBUG] Inserting default exercises...');
  
  // Check if exercises already exist
  final existingExercises = await db.getAllExercises();
  if (existingExercises.isNotEmpty) {
    debugPrint('[DEBUG] Exercises already exist, skipping...');
    return;
  }
  
  // Preset exercises mapped by body part ID
  final presetExercises = <String, List<String>>{
    'body_chest': [
      'Bench Press',
      'Incline Bench Press',
      'Decline Bench Press',
      'Dumbbell Fly',
      'Push-ups',
      'Dips',
    ],
    'body_back': [
      'Deadlift',
      'Pull-ups',
      'Lat Pulldown',
      'Barbell Row',
      'Dumbbell Row',
    ],
    'body_glutes': [
      'Hip Thrust',
      'Glute Bridge',
      'Romanian Deadlift',
      'Cable Kickback',
    ],
    'body_legs': [
      'Squat',
      'Leg Press',
      'Lunges',
      'Leg Extension',
      'Leg Curl',
      'Calf Raise',
    ],
    'body_shoulders': [
      'Overhead Press',
      'Dumbbell Shoulder Press',
      'Lateral Raise',
      'Front Raise',
      'Face Pull',
    ],
    'body_arms': [
      'Barbell Curl',
      'Dumbbell Curl',
      'Hammer Curl',
      'Tricep Pushdown',
      'Tricep Dips',
    ],
    'body_abs': [
      'Crunches',
      'Plank',
      'Leg Raise',
      'Cable Crunch',
      'Russian Twist',
    ],
  };
  
  int exerciseId = 1;
  for (final entry in presetExercises.entries) {
    final bodyPartId = entry.key;
    for (final exerciseName in entry.value) {
      await db.insertExercise(ExercisesCompanion.insert(
        id: 'exercise_${exerciseId++}',
        name: exerciseName,
        bodyPartId: bodyPartId,
        createdAt: DateTime.now().toUtc(),
      ));
    }
  }
  
  debugPrint('[DEBUG] Default exercises inserted successfully');
}
