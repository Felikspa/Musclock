import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/database/database.dart';

class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  /// 备份所有数据
  Future<File> createBackup() async {
    final exportService = _ExportServiceHelper(_db);
    final jsonData = await exportService.exportToJson();
    
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filename = 'muscle_clock_backup_$timestamp.json';
    
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    final file = File('${backupDir.path}/$filename');
    await file.writeAsString(jsonData);
    return file;
  }

  /// 恢复数据
  Future<void> restoreFromBackup(File backupFile) async {
    final jsonString = await backupFile.readAsString();
    final data = json.decode(jsonString) as Map<String, dynamic>;
    
    // 恢复BodyParts
    if (data['bodyParts'] != null) {
      for (final bp in data['bodyParts'] as List) {
        await _db.insertBodyPart(BodyPartsCompanion.insert(
          id: bp['id'],
          name: bp['name'],
          createdAt: DateTime.parse(bp['createdAt']),
          isDeleted: Value(bp['isDeleted'] ?? false),
        ));
      }
    }
    
    // 恢复Exercises
    if (data['exercises'] != null) {
      for (final e in data['exercises'] as List) {
        await _db.insertExercise(ExercisesCompanion.insert(
          id: e['id'],
          name: e['name'],
          bodyPartId: e['bodyPartId'],
          createdAt: DateTime.parse(e['createdAt']),
        ));
      }
    }
    
    // 恢复WorkoutSessions
    if (data['workoutSessions'] != null) {
      for (final s in data['workoutSessions'] as List) {
        await _db.insertSession(WorkoutSessionsCompanion.insert(
          id: s['id'],
          startTime: DateTime.parse(s['startTime']),
          createdAt: DateTime.parse(s['createdAt']),
        ));
      }
    }
    
    // 恢复ExerciseRecords
    if (data['exerciseRecords'] != null) {
      for (final er in data['exerciseRecords'] as List) {
        await _db.insertExerciseRecord(ExerciseRecordsCompanion.insert(
          id: er['id'],
          sessionId: er['sessionId'],
          exerciseId: er['exerciseId'],
        ));
      }
    }
    
    // 恢复SetRecords
    if (data['setRecords'] != null) {
      for (final sr in data['setRecords'] as List) {
        await _db.insertSetRecord(SetRecordsCompanion.insert(
          id: sr['id'],
          exerciseRecordId: sr['exerciseRecordId'],
          weight: sr['weight'],
          reps: sr['reps'],
          orderIndex: sr['orderIndex'],
        ));
      }
    }
    
    // 恢复TrainingPlans
    if (data['trainingPlans'] != null) {
      for (final p in data['trainingPlans'] as List) {
        await _db.insertPlan(TrainingPlansCompanion.insert(
          id: p['id'],
          name: p['name'],
          cycleLengthDays: p['cycleLengthDays'],
          createdAt: DateTime.parse(p['createdAt']),
        ));
      }
    }
    
    // 恢复PlanItems
    if (data['planItems'] != null) {
      for (final pi in data['planItems'] as List) {
        await _db.insertPlanItem(PlanItemsCompanion.insert(
          id: pi['id'],
          planId: pi['planId'],
          dayIndex: pi['dayIndex'],
          bodyPartIds: pi['bodyPartIds'],
        ));
      }
    }
  }

  /// 获取所有备份文件
  Future<List<FileSystemEntity>> getBackupFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');
    if (!await backupDir.exists()) {
      return [];
    }
    return backupDir.listSync();
  }

  /// 分享备份文件
  Future<void> shareBackup(File backupFile) async {
    await Share.shareXFiles([XFile(backupFile.path)]);
  }
}

// Helper class to access private export method
class _ExportServiceHelper {
  final AppDatabase _db;
  _ExportServiceHelper(this._db);
  
  Future<String> exportToJson() async {
    final bodyParts = await _db.getAllBodyParts();
    final exercises = await _db.getAllExercises();
    final sessions = await _db.getAllSessions();
    final plans = await _db.getAllPlans();

    final List<Map<String, dynamic>> exerciseRecords = [];
    final List<Map<String, dynamic>> setRecords = [];
    final List<Map<String, dynamic>> planItems = [];

    for (final session in sessions) {
      final records = await _db.getRecordsBySession(session.id);
      for (final record in records) {
        exerciseRecords.add({
          'id': record.id,
          'sessionId': record.sessionId,
          'exerciseId': record.exerciseId,
        });

        final sets = await _db.getSetsByExerciseRecord(record.id);
        for (final set in sets) {
          setRecords.add({
            'id': set.id,
            'exerciseRecordId': set.exerciseRecordId,
            'weight': set.weight,
            'reps': set.reps,
            'orderIndex': set.orderIndex,
          });
        }
      }
    }

    for (final plan in plans) {
      final items = await _db.getPlanItemsByPlan(plan.id);
      for (final item in items) {
        planItems.add({
          'id': item.id,
          'planId': item.planId,
          'dayIndex': item.dayIndex,
          'bodyPartIds': item.bodyPartIds,
        });
      }
    }

    final data = {
      'version': '1.0',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'bodyParts': bodyParts.map((bp) => {
        'id': bp.id,
        'name': bp.name,
        'createdAt': bp.createdAt.toIso8601String(),
        'isDeleted': bp.isDeleted,
      }).toList(),
      'exercises': exercises.map((e) => {
        'id': e.id,
        'name': e.name,
        'bodyPartId': e.bodyPartId,
        'createdAt': e.createdAt.toIso8601String(),
      }).toList(),
      'workoutSessions': sessions.map((s) => {
        'id': s.id,
        'startTime': s.startTime.toIso8601String(),
        'createdAt': s.createdAt.toIso8601String(),
      }).toList(),
      'exerciseRecords': exerciseRecords,
      'setRecords': setRecords,
      'trainingPlans': plans.map((p) => {
        'id': p.id,
        'name': p.name,
        'cycleLengthDays': p.cycleLengthDays,
        'createdAt': p.createdAt.toIso8601String(),
      }).toList(),
      'planItems': planItems,
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
