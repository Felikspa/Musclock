import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../data/database/database.dart';

class ExportService {
  final AppDatabase _db;

  ExportService(this._db);

  /// 导出所有数据为JSON
  Future<String> exportToJson() async {
    final bodyParts = await _db.getAllBodyParts();
    final exercises = await _db.getAllExercises();
    final sessions = await _db.getAllSessions();
    final plans = await _db.getAllPlans();

    // 收集所有关联数据
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
        'bodyPartIds': e.bodyPartIds,
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

  /// 导出为CSV格式（简化版）
  Future<String> exportToCsv() async {
    final sessions = await _db.getAllSessions();
    final List<String> csvLines = ['Date,Exercise,Body Part,Weight,Reps,Volume'];

    for (final session in sessions) {
      final records = await _db.getRecordsBySession(session.id);
      final date = session.startTime.toLocal().toIso8601String().split('T')[0];

      for (final record in records) {
        if (record.exerciseId == null) continue;
        final exercise = await _db.getExerciseById(record.exerciseId!);
        if (exercise == null) continue;

        // Parse bodyPartIds to get the primary body part
        final bodyPartIds = _parseBodyPartIds(exercise.bodyPartIds);
        final primaryBodyPartId = bodyPartIds.isNotEmpty ? bodyPartIds.first : null;
        final bodyPart = primaryBodyPartId != null ? await _db.getBodyPartById(primaryBodyPartId) : null;
        final sets = await _db.getSetsByExerciseRecord(record.id);

        for (final set in sets) {
          final volume = set.weight * set.reps;
          csvLines.add(
            '$date,${exercise.name},${bodyPart?.name ?? "Unknown"},${set.weight},${set.reps},$volume'
          );
        }
      }
    }

    return csvLines.join('\n');
  }

  /// 保存导出文件
  Future<File> saveExport(String filename) async {
    final jsonData = await exportToJson();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    return await file.writeAsString(jsonData);
  }

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
}
