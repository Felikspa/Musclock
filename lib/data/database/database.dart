import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ============ Tables ============

class BodyParts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get bodyPartId => text().references(BodyParts, #id)();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutSessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get bodyPartIds => text().withDefault(const Constant(''))(); // JSON array of body part IDs
  
  @override
  Set<Column> get primaryKey => {id};
}

class ExerciseRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(WorkoutSessions, #id)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  
  @override
  Set<Column> get primaryKey => {id};
}

class SetRecords extends Table {
  TextColumn get id => text()();
  TextColumn get exerciseRecordId => text().references(ExerciseRecords, #id)();
  RealColumn get weight => real()();
  IntColumn get reps => integer()();
  IntColumn get orderIndex => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class TrainingPlans extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get cycleLengthDays => integer()();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class PlanItems extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text().references(TrainingPlans, #id)();
  IntColumn get dayIndex => integer()();
  TextColumn get bodyPartIds => text()(); // JSON array of body part IDs
  
  @override
  Set<Column> get primaryKey => {id};
}

// ============ Database ============

@DriftDatabase(tables: [
  BodyParts,
  Exercises,
  WorkoutSessions,
  ExerciseRecords,
  SetRecords,
  TrainingPlans,
  PlanItems,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ============ BodyPart Operations ============
  
  Future<List<BodyPart>> getAllBodyParts() =>
      (select(bodyParts)..where((t) => t.isDeleted.equals(false))).get();
  
  Stream<List<BodyPart>> watchAllBodyParts() =>
      (select(bodyParts)..where((t) => t.isDeleted.equals(false))).watch();
  
  Future<BodyPart?> getBodyPartById(String id) =>
      (select(bodyParts)..where((t) => t.id.equals(id))).getSingleOrNull();
  
  Future<int> insertBodyPart(BodyPartsCompanion entry) =>
      into(bodyParts).insert(entry);
  
  Future<bool> updateBodyPart(BodyPartsCompanion entry) =>
      update(bodyParts).replace(entry);
  
  Future<int> softDeleteBodyPart(String id) =>
      (update(bodyParts)..where((t) => t.id.equals(id)))
          .write(const BodyPartsCompanion(isDeleted: Value(true)));

  // ============ Exercise Operations ============
  
  Future<List<Exercise>> getAllExercises() => select(exercises).get();
  
  Stream<List<Exercise>> watchAllExercises() => select(exercises).watch();
  
  Future<List<Exercise>> getExercisesByBodyPart(String bodyPartId) =>
      (select(exercises)..where((t) => t.bodyPartId.equals(bodyPartId))).get();
  
  Stream<List<Exercise>> watchExercisesByBodyPart(String bodyPartId) =>
      (select(exercises)..where((t) => t.bodyPartId.equals(bodyPartId))).watch();
  
  Future<Exercise?> getExerciseById(String id) =>
      (select(exercises)..where((t) => t.id.equals(id))).getSingleOrNull();
  
  Future<int> insertExercise(ExercisesCompanion entry) =>
      into(exercises).insert(entry);
  
  Future<bool> updateExercise(ExercisesCompanion entry) =>
      update(exercises).replace(entry);

  // ============ WorkoutSession Operations ============
  
  Future<List<WorkoutSession>> getAllSessions() =>
      (select(workoutSessions)..orderBy([(t) => OrderingTerm.desc(t.startTime)])).get();
  
  Stream<List<WorkoutSession>> watchAllSessions() =>
      (select(workoutSessions)..orderBy([(t) => OrderingTerm.desc(t.startTime)])).watch();
  
  Future<WorkoutSession?> getSessionById(String id) =>
      (select(workoutSessions)..where((t) => t.id.equals(id))).getSingleOrNull();
  
  Future<List<WorkoutSession>> getSessionsInDateRange(DateTime start, DateTime end) =>
      (select(workoutSessions)
        ..where((t) => t.startTime.isBetweenValues(start, end))
        ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
      .get();
  
  Future<WorkoutSession?> getFirstSession() =>
      (select(workoutSessions)..orderBy([(t) => OrderingTerm.asc(t.startTime)])..limit(1))
      .getSingleOrNull();
  
  Future<int> insertSession(WorkoutSessionsCompanion entry) =>
      into(workoutSessions).insert(entry);
  
  Future<int> deleteSession(String id) =>
      (delete(workoutSessions)..where((t) => t.id.equals(id))).go();

  // ============ ExerciseRecord Operations ============
  
  Future<List<ExerciseRecord>> getRecordsBySession(String sessionId) =>
      (select(exerciseRecords)..where((t) => t.sessionId.equals(sessionId))).get();
  
  Stream<List<ExerciseRecord>> watchRecordsBySession(String sessionId) =>
      (select(exerciseRecords)..where((t) => t.sessionId.equals(sessionId))).watch();
  
  Future<int> insertExerciseRecord(ExerciseRecordsCompanion entry) =>
      into(exerciseRecords).insert(entry);
  
  Future<int> deleteExerciseRecord(String id) =>
      (delete(exerciseRecords)..where((t) => t.id.equals(id))).go();
  
  Future<int> deleteRecordsBySession(String sessionId) =>
      (delete(exerciseRecords)..where((t) => t.sessionId.equals(sessionId))).go();

  // ============ SetRecord Operations ============
  
  Future<List<SetRecord>> getSetsByExerciseRecord(String exerciseRecordId) =>
      (select(setRecords)
        ..where((t) => t.exerciseRecordId.equals(exerciseRecordId))
        ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
      .get();
  
  Stream<List<SetRecord>> watchSetsByExerciseRecord(String exerciseRecordId) =>
      (select(setRecords)
        ..where((t) => t.exerciseRecordId.equals(exerciseRecordId))
        ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
      .watch();
  
  Future<int> insertSetRecord(SetRecordsCompanion entry) =>
      into(setRecords).insert(entry);
  
  Future<bool> updateSetRecord(SetRecordsCompanion entry) =>
      update(setRecords).replace(entry);
  
  Future<int> deleteSetRecord(String id) =>
      (delete(setRecords)..where((t) => t.id.equals(id))).go();
  
  Future<int> deleteSetsByExerciseRecord(String exerciseRecordId) =>
      (delete(setRecords)..where((t) => t.exerciseRecordId.equals(exerciseRecordId))).go();

  // ============ TrainingPlan Operations ============
  
  Future<List<TrainingPlan>> getAllPlans() => select(trainingPlans).get();
  
  Stream<List<TrainingPlan>> watchAllPlans() => select(trainingPlans).watch();
  
  Future<TrainingPlan?> getPlanById(String id) =>
      (select(trainingPlans)..where((t) => t.id.equals(id))).getSingleOrNull();
  
  Future<int> insertPlan(TrainingPlansCompanion entry) =>
      into(trainingPlans).insert(entry);
  
  Future<bool> updatePlan(TrainingPlansCompanion entry) =>
      update(trainingPlans).replace(entry);
  
  Future<int> deletePlan(String id) =>
      (delete(trainingPlans)..where((t) => t.id.equals(id))).go();

  // ============ PlanItem Operations ============
  
  Future<List<PlanItem>> getPlanItemsByPlan(String planId) =>
      (select(planItems)..where((t) => t.planId.equals(planId))).get();
  
  Stream<List<PlanItem>> watchPlanItemsByPlan(String planId) =>
      (select(planItems)..where((t) => t.planId.equals(planId))).watch();
  
  Future<int> insertPlanItem(PlanItemsCompanion entry) =>
      into(planItems).insert(entry);
  
  Future<bool> updatePlanItem(PlanItemsCompanion entry) =>
      update(planItems).replace(entry);
  
  Future<int> deletePlanItem(String id) =>
      (delete(planItems)..where((t) => t.id.equals(id))).go();
  
  Future<int> deletePlanItemsByPlan(String planId) =>
      (delete(planItems)..where((t) => t.planId.equals(planId))).go();

  // ============ Statistics Queries ============
  
  /// Get sessions containing a specific body part
  Future<List<WorkoutSession>> getSessionsByBodyPart(String bodyPartId) async {
    final exerciseIds = await (select(exercises)
      ..where((t) => t.bodyPartId.equals(bodyPartId)))
      .get();
    
    if (exerciseIds.isEmpty) return [];
    
    final exerciseIdsList = exerciseIds.map((e) => e.id).toList();
    final recordIds = await (select(exerciseRecords)
      ..where((t) => t.exerciseId.isIn(exerciseIdsList)))
      .get();
    
    if (recordIds.isEmpty) return [];
    
    final sessionIds = recordIds.map((r) => r.sessionId).toSet().toList();
    return (select(workoutSessions)
      ..where((t) => t.id.isIn(sessionIds))
      ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
      .get();
  }
  
  /// Get total volume for a session
  Future<double> getSessionVolume(String sessionId) async {
    final records = await getRecordsBySession(sessionId);
    double totalVolume = 0;
    
    for (final record in records) {
      final sets = await getSetsByExerciseRecord(record.id);
      for (final set in sets) {
        totalVolume += set.weight * set.reps;
      }
    }
    
    return totalVolume;
  }
  
  /// Get daily volumes for heatmap
  Future<Map<DateTime, double>> getDailyVolumes() async {
    final sessions = await getAllSessions();
    final Map<DateTime, double> dailyVolumes = {};
    
    for (final session in sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      final volume = await getSessionVolume(session.id);
      dailyVolumes[date] = (dailyVolumes[date] ?? 0) + volume;
    }
    
    return dailyVolumes;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'muscle_clock.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
