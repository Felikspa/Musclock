import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'dart:convert';
import '../../data/database/database.dart';
import '../providers/providers.dart';

// ============ State Classes ============

/// State for the workout session
class WorkoutSessionState {
  final String? sessionId;
  final DateTime startTime;
  final List<ExerciseInSession> exercises;
  final bool isActive;

  WorkoutSessionState({
    this.sessionId,
    required this.startTime,
    this.exercises = const [],
    this.isActive = false,
  });

  WorkoutSessionState copyWith({
    String? sessionId,
    DateTime? startTime,
    List<ExerciseInSession>? exercises,
    bool? isActive,
  }) {
    return WorkoutSessionState(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      exercises: exercises ?? this.exercises,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Exercise in the current session
/// Can contain either a specific exercise or just a body part
class ExerciseInSession {
  final String exerciseRecordId;
  final Exercise? exercise;  // Can be null if only bodyPart is stored
  final BodyPart? bodyPart;
  final List<BodyPart> bodyParts;  // All body parts associated with this exercise
  final List<SetInSession> sets;

  ExerciseInSession({
    required this.exerciseRecordId,
    this.exercise,  // Nullable - for body-part-only entries
    this.bodyPart,
    this.bodyParts = const [],
    this.sets = const [],
  });

  ExerciseInSession copyWith({
    String? exerciseRecordId,
    Exercise? exercise,
    BodyPart? bodyPart,
    List<BodyPart>? bodyParts,
    List<SetInSession>? sets,
  }) {
    return ExerciseInSession(
      exerciseRecordId: exerciseRecordId ?? this.exerciseRecordId,
      exercise: exercise ?? this.exercise,
      bodyPart: bodyPart ?? this.bodyPart,
      bodyParts: bodyParts ?? this.bodyParts,
      sets: sets ?? this.sets,
    );
  }

  /// Check if this is a body-part-only entry (no specific exercise)
  bool get isBodyPartOnly => exercise == null && bodyPart != null;
}

/// Set in the current session
class SetInSession {
  final String setRecordId;
  final double weight;
  final int reps;
  final int orderIndex;

  SetInSession({
    required this.setRecordId,
    required this.weight,
    required this.reps,
    required this.orderIndex,
  });
}

// ============ Provider ============

final workoutSessionProvider = StateNotifierProvider<WorkoutSessionNotifier, WorkoutSessionState>((ref) {
  return WorkoutSessionNotifier(ref);
});

// ============ State Notifier ============

class WorkoutSessionNotifier extends StateNotifier<WorkoutSessionState> {
  final Ref _ref;

  WorkoutSessionNotifier(this._ref) : super(WorkoutSessionState(startTime: DateTime.now().toUtc()));

  /// Parse bodyPartIds JSON array string to List<String>
  List<String> _parseBodyPartIds(String? bodyPartIdsJson) {
    // Handle NULL or empty values
    if (bodyPartIdsJson == null || bodyPartIdsJson.isEmpty || bodyPartIdsJson == '[]') return [];
    try {
      final decoded = jsonDecode(bodyPartIdsJson);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> startNewSession() async {
    final db = _ref.read(databaseProvider);
    
    // Check if there's a session within the last hour
    final now = DateTime.now().toUtc();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    // Get all sessions
    final allSessions = await db.getAllSessions();
    
    // Find a session that started within the last hour
    WorkoutSession? recentSession;
    for (final session in allSessions) {
      if (session.startTime.isAfter(oneHourAgo)) {
        recentSession = session;
        break;
      }
    }
    
    if (recentSession != null) {
      // Load existing exercises for the recent session
      final records = await db.getRecordsBySession(recentSession.id);
      final exercisesInSession = <ExerciseInSession>[];
      
      for (final record in records) {
        // Check if this is a body-part-only record (marked with "bodyPart:" prefix)
        if (record.exerciseId != null && record.exerciseId!.startsWith('bodyPart:')) {
          // Extract body part ID from the marker
          final bodyPartId = record.exerciseId!.substring('bodyPart:'.length);
          final bodyPart = await db.getBodyPartById(bodyPartId);
          if (bodyPart != null) {
            exercisesInSession.add(ExerciseInSession(
              exerciseRecordId: record.id,
              exercise: null,  // No specific exercise
              bodyPart: bodyPart,
              sets: [],
            ));
          }
        } else {
          // Normal exercise record
          final exercise = await db.getExerciseById(record.exerciseId!);
          if (exercise != null) {
            // Parse bodyPartIds to get the primary body part
            final bodyPartIds = _parseBodyPartIds(exercise.bodyPartIds);
            final primaryBodyPartId = bodyPartIds.isNotEmpty ? bodyPartIds.first : null;
            final bodyPart = primaryBodyPartId != null ? await db.getBodyPartById(primaryBodyPartId) : null;
            final setRecords = await db.getSetsByExerciseRecord(record.id);
            final setsInSession = setRecords.map((s) => SetInSession(
              setRecordId: s.id,
              weight: s.weight,
              reps: s.reps,
              orderIndex: s.orderIndex,
            )).toList();
            exercisesInSession.add(ExerciseInSession(
              exerciseRecordId: record.id,
              exercise: exercise,
              bodyPart: bodyPart,
              sets: setsInSession,
            ));
          }
        }
      }
      
      // Reuse the recent session with existing exercises
      state = WorkoutSessionState(
        sessionId: recentSession.id,
        startTime: recentSession.startTime,
        isActive: true,
        exercises: exercisesInSession,
      );
      return;
    }
    
    // Create new session
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    await db.insertSession(WorkoutSessionsCompanion.insert(
      id: sessionId,
      startTime: now,
      createdAt: now,
    ));

    // Invalidate sessions provider to refresh UI
    _ref.invalidate(sessionsProvider);

    state = WorkoutSessionState(
      sessionId: sessionId,
      startTime: now,
      isActive: true,
    );
  }

  /// Start a new session with a specific time (for past dates)
  Future<void> startSessionWithTime(DateTime startTime) async {
    final db = _ref.read(databaseProvider);
    final startTimeUtc = startTime.toUtc();
    final now = DateTime.now().toUtc();

    // For past dates, always create a new session with the specified time
    // No need to check for recent sessions since we're adding to a past date
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insertSession(WorkoutSessionsCompanion.insert(
      id: sessionId,
      startTime: startTimeUtc,
      createdAt: now,
    ));

    // Invalidate sessions provider to refresh UI
    _ref.invalidate(sessionsProvider);

    state = WorkoutSessionState(
      sessionId: sessionId,
      startTime: startTimeUtc,
      isActive: true,
    );
  }

  Future<void> addExercise(Exercise exercise) async {
    if (state.sessionId == null) return;

    final db = _ref.read(databaseProvider);
    final recordId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insertExerciseRecord(ExerciseRecordsCompanion.insert(
      id: recordId,
      sessionId: state.sessionId!,
      exerciseId: Value(exercise.id),
    ));

    // Parse bodyPartIds to get all body parts
    final bodyPartIds = _parseBodyPartIds(exercise.bodyPartIds);
    final primaryBodyPartId = bodyPartIds.isNotEmpty ? bodyPartIds.first : null;
    final bodyPart = primaryBodyPartId != null ? await db.getBodyPartById(primaryBodyPartId) : null;
    
    // Get all body parts associated with this exercise
    final List<BodyPart> bodyPartsList = [];
    for (final bpId in bodyPartIds) {
      final bp = await db.getBodyPartById(bpId);
      if (bp != null) {
        bodyPartsList.add(bp);
      }
    }

    final newExercise = ExerciseInSession(
      exerciseRecordId: recordId,
      exercise: exercise,
      bodyPart: bodyPart,
      bodyParts: bodyPartsList,
    );

    state = state.copyWith(
      exercises: [...state.exercises, newExercise],
    );
  }

  /// Add only body part without specific exercise
  /// This creates a placeholder entry that displays the body part name
  Future<void> addBodyPart(BodyPart bodyPart) async {
    if (state.sessionId == null) return;

    final db = _ref.read(databaseProvider);
    final recordId = DateTime.now().millisecondsSinceEpoch.toString();

    // Insert exercise record with special marker for body-part-only
    // Using a prefix to identify body-part-only entries
    await db.insertExerciseRecord(ExerciseRecordsCompanion.insert(
      id: recordId,
      sessionId: state.sessionId!,
      exerciseId: Value('bodyPart:${bodyPart.id}'),  // Marker for body-part-only
    ));

    final newExercise = ExerciseInSession(
      exerciseRecordId: recordId,
      exercise: null,  // No specific exercise
      bodyPart: bodyPart,
    );

    state = state.copyWith(
      exercises: [...state.exercises, newExercise],
    );
  }

  Future<void> addSet(int exerciseIndex, double weight, int reps) async {
    if (state.sessionId == null) return;
    if (exerciseIndex >= state.exercises.length) return;

    final exerciseInSession = state.exercises[exerciseIndex];
    final db = _ref.read(databaseProvider);
    final setId = DateTime.now().millisecondsSinceEpoch.toString();
    final orderIndex = exerciseInSession.sets.length;

    await db.insertSetRecord(SetRecordsCompanion.insert(
      id: setId,
      exerciseRecordId: exerciseInSession.exerciseRecordId,
      weight: weight,
      reps: reps,
      orderIndex: orderIndex,
    ));

    final newSet = SetInSession(
      setRecordId: setId,
      weight: weight,
      reps: reps,
      orderIndex: orderIndex,
    );

    final updatedExercises = [...state.exercises];
    updatedExercises[exerciseIndex] = exerciseInSession.copyWith(
      sets: [...exerciseInSession.sets, newSet],
    );

    state = state.copyWith(exercises: updatedExercises);
  }

  Future<void> deleteSet(int exerciseIndex, int setIndex) async {
    if (exerciseIndex >= state.exercises.length) return;

    final exerciseInSession = state.exercises[exerciseIndex];
    if (setIndex >= exerciseInSession.sets.length) return;

    final setToDelete = exerciseInSession.sets[setIndex];
    final db = _ref.read(databaseProvider);

    await db.deleteSetRecord(setToDelete.setRecordId);

    final updatedSets = [...exerciseInSession.sets];
    updatedSets.removeAt(setIndex);

    // Update order indices
    for (var i = 0; i < updatedSets.length; i++) {
      if (updatedSets[i].orderIndex != i) {
        final newSet = SetInSession(
          setRecordId: updatedSets[i].setRecordId,
          weight: updatedSets[i].weight,
          reps: updatedSets[i].reps,
          orderIndex: i,
        );
        updatedSets[i] = newSet;
      }
    }

    final updatedExercises = [...state.exercises];
    updatedExercises[exerciseIndex] = exerciseInSession.copyWith(sets: updatedSets);

    state = state.copyWith(exercises: updatedExercises);
  }

  Future<void> deleteExercise(int exerciseIndex) async {
    if (exerciseIndex >= state.exercises.length) return;

    final exerciseInSession = state.exercises[exerciseIndex];
    final db = _ref.read(databaseProvider);

    // Delete all sets
    await db.deleteSetsByExerciseRecord(exerciseInSession.exerciseRecordId);
    // Delete exercise record
    await db.deleteExerciseRecord(exerciseInSession.exerciseRecordId);

    final updatedExercises = [...state.exercises];
    updatedExercises.removeAt(exerciseIndex);

    state = state.copyWith(exercises: updatedExercises);
  }

  Future<void> endSession() async {
    if (state.sessionId != null) {
      // Delete empty session if no exercises
      if (state.exercises.isEmpty) {
        final db = _ref.read(databaseProvider);
        await db.deleteSession(state.sessionId!);
      }
    }

    state = WorkoutSessionState(startTime: DateTime.now().toUtc());
  }

  /// Start a new session with session merge logic (1-hour window)
  /// This is called from AddExerciseSheet when saving exercises
  /// Returns the session that was either reused or created
  Future<WorkoutSession?> startSessionAndAddExercise() async {
    final db = _ref.read(databaseProvider);
    
    // Check if there's a session within the last hour
    final now = DateTime.now().toUtc();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    // Get all sessions
    final allSessions = await db.getAllSessions();
    
    // Find a session that started within the last hour
    WorkoutSession? recentSession;
    for (final session in allSessions) {
      if (session.startTime.isAfter(oneHourAgo)) {
        recentSession = session;
        break;
      }
    }
    
    if (recentSession != null) {
      // Load existing exercises for the recent session
      final records = await db.getRecordsBySession(recentSession.id);
      final exercisesInSession = <ExerciseInSession>[];
      
      for (final record in records) {
        // Check if this is a body-part-only record (marked with "bodyPart:" prefix)
        if (record.exerciseId != null && record.exerciseId!.startsWith('bodyPart:')) {
          // Extract body part ID from the marker
          final bodyPartId = record.exerciseId!.substring('bodyPart:'.length);
          final bodyPart = await db.getBodyPartById(bodyPartId);
          if (bodyPart != null) {
            exercisesInSession.add(ExerciseInSession(
              exerciseRecordId: record.id,
              exercise: null,  // No specific exercise
              bodyPart: bodyPart,
              sets: [],
            ));
          }
        } else {
          // Normal exercise record
          final exercise = await db.getExerciseById(record.exerciseId!);
          if (exercise != null) {
            // Parse bodyPartIds to get the primary body part
            final bodyPartIds = _parseBodyPartIds(exercise.bodyPartIds);
            final primaryBodyPartId = bodyPartIds.isNotEmpty ? bodyPartIds.first : null;
            final bodyPart = primaryBodyPartId != null ? await db.getBodyPartById(primaryBodyPartId) : null;
            final setRecords = await db.getSetsByExerciseRecord(record.id);
            final setsInSession = setRecords.map((s) => SetInSession(
              setRecordId: s.id,
              weight: s.weight,
              reps: s.reps,
              orderIndex: s.orderIndex,
            )).toList();
            exercisesInSession.add(ExerciseInSession(
              exerciseRecordId: record.id,
              exercise: exercise,
              bodyPart: bodyPart,
              sets: setsInSession,
            ));
          }
        }
      }
      
      // Reuse the recent session with existing exercises
      state = WorkoutSessionState(
        sessionId: recentSession.id,
        startTime: recentSession.startTime,
        isActive: true,
        exercises: exercisesInSession,
      );
      return recentSession;
    }
    
    // Create new session
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    await db.insertSession(WorkoutSessionsCompanion.insert(
      id: sessionId,
      startTime: now,
      createdAt: now,
    ));

    // Invalidate sessions provider to refresh UI
    _ref.invalidate(sessionsProvider);

    state = WorkoutSessionState(
      sessionId: sessionId,
      startTime: now,
      isActive: true,
    );
    
    return WorkoutSession(id: sessionId, startTime: now, createdAt: now, bodyPartIds: '[]');
  }

  /// Load an existing session for editing
  /// This is called when user taps on a session card to edit it
  Future<void> loadSessionForEditing(WorkoutSession session) async {
    final db = _ref.read(databaseProvider);
    
    // Load existing exercises for the session
    final records = await db.getRecordsBySession(session.id);
    final exercisesInSession = <ExerciseInSession>[];
    
    for (final record in records) {
      // Check if this is a body-part-only record (marked with "bodyPart:" prefix)
      if (record.exerciseId != null && record.exerciseId!.startsWith('bodyPart:')) {
        // Extract body part ID from the marker
        final bodyPartId = record.exerciseId!.substring('bodyPart:'.length);
        final bodyPart = await db.getBodyPartById(bodyPartId);
        if (bodyPart != null) {
          // Load sets for body-part-only record
          final setRecords = await db.getSetsByExerciseRecord(record.id);
          final setsInSession = setRecords.map((s) => SetInSession(
            setRecordId: s.id,
            weight: s.weight,
            reps: s.reps,
            orderIndex: s.orderIndex,
          )).toList();
          exercisesInSession.add(ExerciseInSession(
            exerciseRecordId: record.id,
            exercise: null,  // No specific exercise
            bodyPart: bodyPart,
            sets: setsInSession,
          ));
        }
      } else {
        // Normal exercise record
        final exercise = await db.getExerciseById(record.exerciseId!);
        if (exercise != null) {
          // Parse bodyPartIds to get the primary body part
            final bodyPartIds = _parseBodyPartIds(exercise.bodyPartIds);
            final primaryBodyPartId = bodyPartIds.isNotEmpty ? bodyPartIds.first : null;
            final bodyPart = primaryBodyPartId != null ? await db.getBodyPartById(primaryBodyPartId) : null;
          final setRecords = await db.getSetsByExerciseRecord(record.id);
          final setsInSession = setRecords.map((s) => SetInSession(
            setRecordId: s.id,
            weight: s.weight,
            reps: s.reps,
            orderIndex: s.orderIndex,
          )).toList();
          exercisesInSession.add(ExerciseInSession(
            exerciseRecordId: record.id,
            exercise: exercise,
            bodyPart: bodyPart,
            sets: setsInSession,
          ));
        }
      }
    }
    
    // Set the session state to active with loaded exercises
    state = WorkoutSessionState(
      sessionId: session.id,
      startTime: session.startTime,
      isActive: true,
      exercises: exercisesInSession,
    );
  }
}
