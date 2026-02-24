import '../../data/database/database.dart';

/// Repository for Session, Exercise, and BodyPart related database operations
/// This follows Clean Architecture by isolating database operations from the UI layer
class SessionRepository {
  final AppDatabase _db;

  SessionRepository(this._db);

  // ===== WorkoutSession operations =====

  Future<List<WorkoutSession>> getAllSessions() => _db.getAllSessions();

  Future<WorkoutSession?> getSessionById(String id) => _db.getSessionById(id);

  Future<List<WorkoutSession>> getSessionsInDateRange(
          DateTime start, DateTime end) =>
      _db.getSessionsInDateRange(start, end);

  Future<WorkoutSession?> getFirstSession() => _db.getFirstSession();

  Future<int> insertSession(WorkoutSessionsCompanion session) =>
      _db.insertSession(session);

  Future<int> deleteSession(String id) => _db.deleteSession(id);

  Future<List<WorkoutSession>> getSessionsByBodyPart(String bodyPartId) =>
      _db.getSessionsByBodyPart(bodyPartId);

  Future<double> getSessionVolume(String sessionId) =>
      _db.getSessionVolume(sessionId);

  // ===== ExerciseRecord operations =====

  Future<List<ExerciseRecord>> getRecordsBySession(String sessionId) =>
      _db.getRecordsBySession(sessionId);

  Future<int> insertExerciseRecord(ExerciseRecordsCompanion record) =>
      _db.insertExerciseRecord(record);

  Future<int> deleteExerciseRecord(String id) =>
      _db.deleteExerciseRecord(id);

  Future<int> deleteRecordsBySession(String sessionId) =>
      _db.deleteRecordsBySession(sessionId);

  // ===== Exercise operations =====

  Future<List<Exercise>> getAllExercises() => _db.getAllExercises();

  Future<List<Exercise>> getExercisesByBodyPart(String bodyPartId) =>
      _db.getExercisesByBodyPart(bodyPartId);

  Future<Exercise?> getExerciseById(String id) => _db.getExerciseById(id);

  Future<int> insertExercise(ExercisesCompanion exercise) =>
      _db.insertExercise(exercise);

  Future<int> updateExercise(String id, {String? name, String? bodyPartIds}) =>
      _db.updateExercise(id, name: name, bodyPartIds: bodyPartIds);

  // ===== BodyPart operations =====

  Future<List<BodyPart>> getAllBodyParts() => _db.getAllBodyParts();

  Future<BodyPart?> getBodyPartById(String id) => _db.getBodyPartById(id);

  Future<int> insertBodyPart(BodyPartsCompanion bodyPart) =>
      _db.insertBodyPart(bodyPart);

  Future<bool> updateBodyPart(BodyPartsCompanion bodyPart) =>
      _db.updateBodyPart(bodyPart);

  Future<int> softDeleteBodyPart(String id) => _db.softDeleteBodyPart(id);

  // ===== SetRecord operations =====

  Future<List<SetRecord>> getSetsByExerciseRecord(String exerciseRecordId) =>
      _db.getSetsByExerciseRecord(exerciseRecordId);

  Future<int> insertSetRecord(SetRecordsCompanion setRecord) =>
      _db.insertSetRecord(setRecord);

  Future<int> updateSetRecord(String id, {double? weight, int? reps, int? orderIndex}) =>
      _db.updateSetRecord(id, weight: weight, reps: reps, orderIndex: orderIndex);

  Future<int> deleteSetRecord(String id) => _db.deleteSetRecord(id);

  Future<int> deleteSetsByExerciseRecord(String exerciseRecordId) =>
      _db.deleteSetsByExerciseRecord(exerciseRecordId);

  // ===== JOIN Query Methods for Performance Optimization =====

  /// Get all exercise records with exercise and bodyPart data for a session in one query
  Future<List<ExerciseRecordWithDetails>> getSessionExerciseRecordsWithDetails(String sessionId) =>
      _db.getSessionExerciseRecordsWithDetails(sessionId);

  /// Get all sets for multiple exercise records in one query
  Future<Map<String, List<SetRecord>>> getSetsByExerciseRecordIds(List<String> exerciseRecordIds) =>
      _db.getSetsByExerciseRecordIds(exerciseRecordIds);

  /// Get all details for multiple sessions in optimized way
  Future<Map<String, List<ExerciseRecordWithDetails>>> getMultipleSessionsExerciseRecordsWithDetails(
          List<String> sessionIds) =>
      _db.getMultipleSessionsExerciseRecordsWithDetails(sessionIds);
}
