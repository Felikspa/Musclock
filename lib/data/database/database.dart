import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/utils/date_time_utils.dart';

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
  TextColumn get bodyPartIds => text().withDefault(const Constant('[]'))(); // JSON array of body part IDs
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
  TextColumn get exerciseId => text().nullable().references(Exercises, #id)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
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
  // Execution tracking fields
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  IntColumn get currentDayIndex => integer().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  // Last executed time for sorting
  DateTimeColumn get lastExecutedAt => dateTime().nullable()();

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

// Data class for JOIN queries
class ExerciseRecordWithDetails {
  final ExerciseRecord record;
  final Exercise? exercise;  // Nullable for body-part-only records
  final BodyPart bodyPart;
  final List<BodyPart> bodyParts; // All body parts for this exercise
  
  ExerciseRecordWithDetails({
    required this.record,
    this.exercise,  // Nullable for body-part-only records
    required this.bodyPart,
    List<BodyPart>? bodyParts,
  }) : bodyParts = bodyParts ?? [bodyPart];
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
  // Singleton pattern - ensure only one instance exists
  static AppDatabase? _instance;

  AppDatabase._internal() : super(_openConnection());

  static AppDatabase get instance {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  // Factory constructor for backward compatibility
  factory AppDatabase() => AppDatabase.instance;

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Add is_deleted column to exercise_records table
          await m.addColumn(exerciseRecords, exerciseRecords.isDeleted);
        }
        if (from < 3) {
          // Migrate bodyPartId to bodyPartIds
          // Since we're changing from single string to JSON array, we need custom migration
          await _migrateBodyPartIdToBodyPartIds();
        }
        if (from < 4) {
          // Add execution tracking fields to TrainingPlans
          await m.addColumn(trainingPlans, trainingPlans.isActive);
          await m.addColumn(trainingPlans, trainingPlans.currentDayIndex);
          await m.addColumn(trainingPlans, trainingPlans.startDate);
        }
        if (from < 5) {
          // Add lastExecutedAt field for sorting plans by execution time
          await m.addColumn(trainingPlans, trainingPlans.lastExecutedAt);
        }
      },
    );
  }

  /// Custom migration to convert bodyPartId (single string) to bodyPartIds (JSON array)
  Future<void> _migrateBodyPartIdToBodyPartIds() async {
    try {
      // First, check if old body_part_id column exists and has data
      // Use a safe approach: try to get info about the column
      final result = await customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='exercises'",
      ).get();
      
      if (result.isEmpty) return;
      
      // Try to check if old column exists using PRAGMA (safer approach)
      final tableInfo = await customSelect(
        "PRAGMA table_info(exercises)",
      ).get();
      
      final columnNames = tableInfo.map((row) => row.read<String>('name')).toList();
      final hasOldColumn = columnNames.contains('body_part_id');
      final hasNewColumn = columnNames.contains('body_part_ids');
      
      // If new column doesn't exist, we need to create it first
      if (!hasNewColumn && hasOldColumn) {
        // Rename old column to new column name
        await customStatement(
          'ALTER TABLE exercises RENAME COLUMN body_part_id TO body_part_ids',
        );
      }
      
      // Now ensure all records have valid bodyPartIds (not NULL or empty)
      // Get all exercises and fix any NULL or empty body_part_ids
      final allExercises = await customSelect(
        "SELECT id, body_part_ids FROM exercises WHERE body_part_ids IS NULL OR body_part_ids = '' OR body_part_ids = '[]'",
      ).get();
      
      for (final row in allExercises) {
        final id = row.read<String>('id');
        final currentValue = row.read<String?>('body_part_ids');
        
        // If NULL or empty, set default to empty array
        final newValue = (currentValue == null || currentValue.isEmpty) 
            ? '[]' 
            : currentValue;
        
        await (update(exercises)..where((t) => t.id.equals(id)))
            .write(ExercisesCompanion(bodyPartIds: Value(newValue)));
      }
    } catch (e) {
      // Log error but continue - this shouldn't break the app
      // On fresh installs, this migration won't do anything
    }
  }

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
  
  /// Get exercises by body part (checks if bodyPartIds JSON array contains the bodyPartId)
  Future<List<Exercise>> getExercisesByBodyPart(String bodyPartId) async {
    final allExercises = await getAllExercises();
    return allExercises.where((e) {
      // Parse bodyPartIds JSON array
      final ids = parseBodyPartIds(e.bodyPartIds);
      return ids.contains(bodyPartId);
    }).toList();
  }
  
  /// Watch exercises by body part (checks if bodyPartIds JSON array contains the bodyPartId)
  Stream<List<Exercise>> watchExercisesByBodyPart(String bodyPartId) {
    return watchAllExercises().map((exerciseList) {
      return exerciseList.where((e) {
        final ids = parseBodyPartIds(e.bodyPartIds);
        return ids.contains(bodyPartId);
      }).toList();
    });
  }
  
  Future<Exercise?> getExerciseById(String id) =>
      (select(exercises)..where((t) => t.id.equals(id))).getSingleOrNull();
  
  Future<int> insertExercise(ExercisesCompanion entry) =>
      into(exercises).insert(entry);
  
  Future<int> updateExercise(String id, {String? name, String? bodyPartIds}) async {
    return (update(exercises)..where((t) => t.id.equals(id))).write(
      ExercisesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        bodyPartIds: bodyPartIds != null ? Value(bodyPartIds) : const Value.absent(),
      ),
    );
  }

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
  
  /// Get all exercise records (excluding soft-deleted) for a session
  Future<List<ExerciseRecord>> getRecordsBySession(String sessionId) =>
      (select(exerciseRecords)
        ..where((t) => t.sessionId.equals(sessionId) & t.isDeleted.equals(false)))
      .get();
  
  /// Watch all exercise records (excluding soft-deleted) for a session
  Stream<List<ExerciseRecord>> watchRecordsBySession(String sessionId) =>
      (select(exerciseRecords)
        ..where((t) => t.sessionId.equals(sessionId) & t.isDeleted.equals(false)))
      .watch();
  
  /// Get all exercise records including deleted (for sync)
  Future<List<ExerciseRecord>> getAllExerciseRecordsIncludingDeleted() =>
      select(exerciseRecords).get();
  
  /// Soft delete an exercise record
  Future<int> softDeleteExerciseRecord(String id) =>
      (update(exerciseRecords)..where((t) => t.id.equals(id)))
          .write(const ExerciseRecordsCompanion(isDeleted: Value(true)));
  
  /// Hard delete an exercise record (for sync from cloud)
  Future<int> hardDeleteExerciseRecord(String id) =>
      (delete(exerciseRecords)..where((t) => t.id.equals(id))).go();
  
  Future<int> insertExerciseRecord(ExerciseRecordsCompanion entry) =>
      into(exerciseRecords).insert(entry);
  
  Future<int> deleteExerciseRecord(String id) =>
      (delete(exerciseRecords)..where((t) => t.id.equals(id))).go();
  
  /// Soft delete exercise record and cascade delete sets
  Future<void> softDeleteExerciseRecordCascade(String exerciseRecordId) async {
    // Soft delete the exercise record
    await softDeleteExerciseRecord(exerciseRecordId);
    // Hard delete all associated set records (they don't need soft delete)
    await deleteSetsByExerciseRecord(exerciseRecordId);
  }
  
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
  
  Future<int> updateSetRecord(String id, {double? weight, int? reps, int? orderIndex}) async {
    return (update(setRecords)..where((t) => t.id.equals(id))).write(
      SetRecordsCompanion(
        weight: weight != null ? Value(weight) : const Value.absent(),
        reps: reps != null ? Value(reps) : const Value.absent(),
        orderIndex: orderIndex != null ? Value(orderIndex) : const Value.absent(),
      ),
    );
  }
  
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
  
  Future<int> updatePlan(TrainingPlansCompanion entry) =>
      (update(trainingPlans)..where((t) => t.id.equals(entry.id.value)))
          .write(entry);
  
  Future<int> deletePlan(String id) =>
      (delete(trainingPlans)..where((t) => t.id.equals(id))).go();

  Future<bool> isPlanNameExists(String name) async {
    final query = select(trainingPlans)
      ..where((t) => t.name.equals(name));
    final result = await query.get();
    return result.isNotEmpty;
  }

  /// Get the currently active (executing) plan
  Future<TrainingPlan?> getActivePlan() async {
    final query = select(trainingPlans)
      ..where((t) => t.isActive.equals(true));
    return query.getSingleOrNull();
  }

  /// Set a plan as active (starts execution)
  /// This will deactivate any other active plans first
  Future<void> setActivePlan(String planId, int currentDayIndex) async {
    await transaction(() async {
      // First, deactivate all plans
      await (update(trainingPlans)..where((t) => t.isActive.equals(true)))
          .write(const TrainingPlansCompanion(
        isActive: Value(false),
      ));

      // Then activate the selected plan
      await (update(trainingPlans)..where((t) => t.id.equals(planId)))
          .write(TrainingPlansCompanion(
        isActive: const Value(true),
        currentDayIndex: Value(currentDayIndex),
        startDate: Value(DateTime.now().toUtc()),
      ));
    });
  }

  /// Deactivate the current active plan (stop execution)
  Future<void> clearActivePlan() async {
    await (update(trainingPlans)..where((t) => t.isActive.equals(true)))
        .write(const TrainingPlansCompanion(
      isActive: Value(false),
      currentDayIndex: Value(null),
      startDate: Value(null),
    ));
  }

  /// Update the current day index of the active plan
  Future<void> updateActivePlanDayIndex(int dayIndex) async {
    await (update(trainingPlans)..where((t) => t.isActive.equals(true)))
        .write(TrainingPlansCompanion(
      currentDayIndex: Value(dayIndex),
    ));
  }

  /// Update the last executed time for a plan (used for sorting)
  Future<void> updatePlanLastExecuted(String planId) async {
    await (update(trainingPlans)..where((t) => t.id.equals(planId)))
        .write(TrainingPlansCompanion(
      lastExecutedAt: Value(DateTime.now().toUtc()),
    ));
  }

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

  // ============ JOIN Queries for Performance Optimization ============
  
  /// Helper to parse bodyPartIds JSON array
  List<String> parseBodyPartIds(String? bodyPartIdsJson) {
    // Handle NULL or empty values
    if (bodyPartIdsJson == null || bodyPartIdsJson.isEmpty || bodyPartIdsJson == '[]') return [];
    try {
      final cleaned = bodyPartIdsJson.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
      if (cleaned.isEmpty) return [];
      return cleaned.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Get all exercise records with exercise and bodyPart data for a session in one query
  /// This eliminates N+1 query problem
  Future<List<ExerciseRecordWithDetails>> getSessionExerciseRecordsWithDetails(String sessionId) async {
    // Get all exercise records for the session
    final records = await (select(exerciseRecords)
      ..where((t) => t.sessionId.equals(sessionId) & t.isDeleted.equals(false)))
      .get();
    
    final List<ExerciseRecordWithDetails> results = [];
    
    for (final record in records) {
      // Handle body-part-only records (marked with "bodyPart:" prefix)
      if (record.exerciseId != null && record.exerciseId!.startsWith('bodyPart:')) {
        final bodyPartId = record.exerciseId!.substring('bodyPart:'.length);
        final bodyPart = await getBodyPartById(bodyPartId);
        if (bodyPart != null) {
          results.add(ExerciseRecordWithDetails(
            record: record,
            exercise: null,
            bodyPart: bodyPart,
            bodyParts: [bodyPart],
          ));
        }
        continue;
      }
      
      // Get exercise by ID
      final exercise = await getExerciseById(record.exerciseId ?? '');
      if (exercise == null) continue;
      
      // Get all body parts for this exercise
      final bodyPartIds = parseBodyPartIds(exercise.bodyPartIds);
      final bodyPartsList = <BodyPart>[];
      BodyPart? primaryBodyPart;
      
      for (final bpId in bodyPartIds) {
        final bp = await getBodyPartById(bpId);
        if (bp != null) {
          bodyPartsList.add(bp);
          primaryBodyPart ??= bp;
        }
      }
      
      if (primaryBodyPart != null) {
        results.add(ExerciseRecordWithDetails(
          record: record,
          exercise: exercise,
          bodyPart: primaryBodyPart,
          bodyParts: bodyPartsList,
        ));
      }
    }
    
    return results;
  }
  
  /// Get all sets for multiple exercise records in one query
  Future<Map<String, List<SetRecord>>> getSetsByExerciseRecordIds(List<String> exerciseRecordIds) async {
    if (exerciseRecordIds.isEmpty) return {};
    
    final records = await (select(setRecords)
      ..where((t) => t.exerciseRecordId.isIn(exerciseRecordIds))
      ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
      .get();
    
    final Map<String, List<SetRecord>> result = {};
    for (final record in records) {
      result.putIfAbsent(record.exerciseRecordId, () => []).add(record);
    }
    return result;
  }
  
  /// Get all details for multiple sessions in optimized way
  Future<Map<String, List<ExerciseRecordWithDetails>>> getMultipleSessionsExerciseRecordsWithDetails(
      List<String> sessionIds) async {
    if (sessionIds.isEmpty) return {};
    
    final Map<String, List<ExerciseRecordWithDetails>> result = {};
    
    // Get all exercise records for these sessions (exclude bodyPart: prefix)
    final allRecords = await (select(exerciseRecords)
      ..where((t) => t.sessionId.isIn(sessionIds) & 
                     t.exerciseId.isNotNull() &
                     t.isDeleted.equals(false)))
      .get();
    
    // Also get body-part-only records
    final bodyPartRecords = await (select(exerciseRecords)
      ..where((t) => t.sessionId.isIn(sessionIds) & 
                     t.exerciseId.like('bodyPart:%') &
                     t.isDeleted.equals(false)))
      .get();
    
    // Process normal exercise records
    for (final record in allRecords) {
      if (record.exerciseId == null) continue;
      
      final exercise = await getExerciseById(record.exerciseId!);
      if (exercise == null) continue;
      
      // Get all body parts for this exercise
      final bodyPartIds = parseBodyPartIds(exercise.bodyPartIds);
      final bodyPartsList = <BodyPart>[];
      BodyPart? primaryBodyPart;
      
      for (final bpId in bodyPartIds) {
        final bp = await getBodyPartById(bpId);
        if (bp != null) {
          bodyPartsList.add(bp);
          primaryBodyPart ??= bp;
        }
      }
      
      if (primaryBodyPart != null) {
        result.putIfAbsent(record.sessionId, () => []).add(ExerciseRecordWithDetails(
          record: record,
          exercise: exercise,
          bodyPart: primaryBodyPart,
          bodyParts: bodyPartsList,
        ));
      }
    }
    
    // Process body-part-only records
    for (final record in bodyPartRecords) {
      if (record.exerciseId == null) continue;
      final bodyPartId = record.exerciseId!.substring('bodyPart:'.length);
      final bodyPart = await getBodyPartById(bodyPartId);
      if (bodyPart != null) {
        result.putIfAbsent(record.sessionId, () => []).add(ExerciseRecordWithDetails(
          record: record,
          exercise: null,  // No specific exercise
          bodyPart: bodyPart,
          bodyParts: [bodyPart],
        ));
      }
    }
    
    return result;
  }

  // ============ Statistics Queries ============
  
  /// Get sessions containing a specific body part
  Future<List<WorkoutSession>> getSessionsByBodyPart(String targetBodyPartId) async {
    // Get all exercises and filter by bodyPartIds containing targetBodyPartId
    final allExercises = await getAllExercises();
    final matchingExercises = allExercises.where((e) {
      final bodyPartIds = parseBodyPartIds(e.bodyPartIds);
      return bodyPartIds.contains(targetBodyPartId);
    }).toList();
    
    if (matchingExercises.isEmpty) return [];
    
    final exerciseIdsList = matchingExercises.map((e) => e.id).toList();
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
      // 使用本地时间获取日期，确保热力图显示正确的本地日期
      final localStartTime = DateTimeUtils.toLocalTime(session.startTime);
      final date = DateTime(
        localStartTime.year,
        localStartTime.month,
        localStartTime.day,
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
