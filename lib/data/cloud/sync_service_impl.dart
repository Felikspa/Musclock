import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/utils/date_time_utils.dart';
import '../database/database.dart';
import 'models/sync_result.dart';

/// Cloud sync service implementation (Supabase)
class CloudSyncService {
  final SupabaseClient _client;
  final AppDatabase _database;
  
  // Metadata storage
  static const String _metadataKey = 'sync_metadata';
  final FlutterSecureStorage _storage;
  SyncMetadata? _lastSyncMetadata;

  // Table name mapping (Local -> Cloud)
  static const Map<String, String> _tableNameMap = {
    'body_parts': 'body_parts',
    'exercises': 'exercises', 
    'workout_sessions': 'workout_sessions',
    'exercise_records': 'exercise_records',
    'set_records': 'set_records',
    'training_plans': 'training_plans',
    'plan_items': 'plan_items',
  };

  CloudSyncService(this._client, this._database, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Get last sync metadata
  Future<SyncMetadata?> getLastSyncMetadata() async {
    if (_lastSyncMetadata != null) return _lastSyncMetadata;
    
    final jsonStr = await _storage.read(key: _metadataKey);
    if (jsonStr != null) {
      try {
        // Simple JSON parsing if not using dart:convert
        // Or better, just store individual fields. 
        // But let's reuse the existing simple parser logic if needed, 
        // or just assume it's a valid JSON string if we wrote it with jsonEncode.
        // The previous code had a custom parser. I'll implement a simple one or use regex.
        // Actually, let's just use a simple approach: if it fails, return null.
        // Since I'm rewriting, I'll use a simpler storage format or just try to parse.
        // Wait, I can't import dart:convert easily if not already there? 
        // Yes I can. But let's stick to the previous custom parser logic for compatibility 
        // if existing data is there? No, migration means we can start fresh.
        // But for safety, I will wrap in try-catch.
        
        // Re-implementing a basic parser for the stored format:
        // {"user_id": "...", "last_sync_time": "..."}
        if (jsonStr.startsWith('{') && jsonStr.endsWith('}')) {
             final content = jsonStr.substring(1, jsonStr.length - 1);
             final Map<String, dynamic> map = {};
             final pairs = content.split(', ');
             for (final pair in pairs) {
               final parts = pair.split(': ');
               if (parts.length >= 2) {
                 final key = parts[0].replaceAll('"', '');
                 // Value might contain : (e.g. time), so join the rest
                 final value = parts.sublist(1).join(': ').replaceAll('"', '');
                 map[key] = value == 'null' ? null : value;
               }
             }
             _lastSyncMetadata = SyncMetadata.fromJson(map);
        }
      } catch (e) {
        debugPrint('Failed to parse sync metadata: $e');
      }
    }
    return _lastSyncMetadata;
  }

  /// Save sync metadata
  Future<void> _saveSyncMetadata(SyncMetadata metadata) async {
    _lastSyncMetadata = metadata;
    // Simple serialization
    final map = metadata.toJson();
    final entries = map.entries.map((e) => '"${e.key}": "${e.value}"').join(', ');
    final jsonStr = '{$entries}';
    
    await _storage.write(key: _metadataKey, value: jsonStr);
  }

  /// Perform full sync
  Future<SyncResult> syncAll() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return SyncResult.failure('User not logged in');
    }

    try {
      int uploaded = 0;
      int downloaded = 0;

      for (final entry in _tableNameMap.entries) {
        final localTable = entry.key;
        final cloudTable = entry.value;

        // 1. Upload
        uploaded += await _uploadTable(localTable, cloudTable, user.id);

        // 2. Download
        downloaded += await _downloadTable(localTable, cloudTable, user.id);
      }

      // Update metadata
      await _saveSyncMetadata(SyncMetadata(
        userId: user.id,
        lastSyncTime: DateTime.now(),
        syncVersion: (_lastSyncMetadata?.syncVersion ?? 0) + 1,
      ));

      return SyncResult.success(
        uploadedCount: uploaded,
        downloadedCount: downloaded,
      );
    } catch (e) {
      debugPrint('Sync error: $e');
      return SyncResult.failure(e.toString());
    }
  }

  /// Upload data only
  Future<SyncResult> uploadData() async {
    final user = _client.auth.currentUser;
    if (user == null) return SyncResult.failure('User not logged in');

    try {
      int uploaded = 0;
      for (final entry in _tableNameMap.entries) {
        uploaded += await _uploadTable(entry.key, entry.value, user.id);
      }
      
      await _saveSyncMetadata(SyncMetadata(
        userId: user.id,
        lastSyncTime: DateTime.now(),
        syncVersion: (_lastSyncMetadata?.syncVersion ?? 0) + 1,
      ));

      return SyncResult.success(uploadedCount: uploaded);
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }

  /// Download data only
  Future<SyncResult> downloadData() async {
    final user = _client.auth.currentUser;
    if (user == null) return SyncResult.failure('User not logged in');

    try {
      int downloaded = 0;
      for (final entry in _tableNameMap.entries) {
        downloaded += await _downloadTable(entry.key, entry.value, user.id);
      }
      
      await _saveSyncMetadata(SyncMetadata(
        userId: user.id,
        lastSyncTime: DateTime.now(),
        syncVersion: (_lastSyncMetadata?.syncVersion ?? 0) + 1,
      ));

      return SyncResult.success(downloadedCount: downloaded);
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }

  Future<int> _uploadTable(String localTable, String cloudTable, String userId) async {
    final localData = await _getLocalTableData(localTable);
    if (localData.isEmpty) return 0;

    // Separate data into to-upload and to-delete based on is_deleted flag
    final dataToUpload = <Map<String, dynamic>>[];
    final idsToDelete = <String>[];
    
    for (final item in localData) {
      final isDeleted = item['is_deleted'] == true || item['is_deleted'] == 1;
      if (isDeleted) {
        // For soft-deleted records, add to delete list
        idsToDelete.add(item['id']);
      } else {
        dataToUpload.add(item);
      }
    }
    
    int count = 0;
    
    // First, delete soft-deleted records from cloud
    for (final id in idsToDelete) {
      try {
        await _client.from(cloudTable).delete().eq('id', id).eq('user_id', userId);
        count++;
      } catch (e) {
        debugPrint('Error deleting $cloudTable record $id: $e');
      }
    }
    
    // Then, upload non-deleted records
    if (dataToUpload.isNotEmpty) {
      final preparedData = dataToUpload.map((e) => _prepareCloudData(e, userId)).toList();
      
      // Supabase upsert in batches
      for (var i = 0; i < preparedData.length; i += 100) {
        final batch = preparedData.skip(i).take(100).toList();
        await _client.from(cloudTable).upsert(batch);
        count += batch.length;
      }
    }
    return count;
  }

  Future<int> _downloadTable(String localTable, String cloudTable, String userId) async {
    final List<dynamic> cloudRecords = await _client
        .from(cloudTable)
        .select()
        .eq('user_id', userId);
    
    int count = 0;
    for (final record in cloudRecords) {
      if (record is Map<String, dynamic>) {
        // For exercise_records, check if local record is already soft-deleted
        if (localTable == 'exercise_records') {
          final localId = record['id'];
          final cloudIsDeleted = record['is_deleted'] == true || record['is_deleted'] == 1;
          
          // Get local record to check its deletion status
          final localRecords = await _database.getAllExerciseRecordsIncludingDeleted();
          final localRecord = localRecords.where((r) => r.id == localId).firstOrNull;
          
          if (localRecord != null && localRecord.isDeleted) {
            // Local is already soft-deleted, skip this cloud record
            continue;
          }
          
          // If cloud record is deleted, also soft-delete local
          if (cloudIsDeleted) {
            await _database.softDeleteExerciseRecord(localId);
            count++;
            continue;
          }
        }
        
        await _updateLocalTableData(localTable, record);
        count++;
      }
    }
    return count;
  }

  /// Prepare data for cloud upload (add user_id)
  Map<String, dynamic> _prepareCloudData(Map<String, dynamic> localData, String userId) {
    final data = Map<String, dynamic>.from(localData);
    data['user_id'] = userId;
    
    // Ensure timestamps are ISO8601
    if (data['created_at'] is DateTime) {
      data['created_at'] = (data['created_at'] as DateTime).toIso8601String();
    }
    return data;
  }

  /// Get local table data as Map
  Future<List<Map<String, dynamic>>> _getLocalTableData(String tableName) async {
    switch (tableName) {
      case 'body_parts':
        final parts = await _database.getAllBodyParts();
        return parts.map((p) => {
          'id': p.id,
          'name': p.name,
          'created_at': p.createdAt.toIso8601String(),
          'is_deleted': p.isDeleted,
        }).toList();
      case 'exercises':
        final exercises = await _database.getAllExercises();
        return exercises.map((e) => {
          'id': e.id,
          'name': e.name,
          'body_part_ids': e.bodyPartIds,
          'created_at': e.createdAt.toIso8601String(),
        }).toList();
      case 'workout_sessions':
        final sessions = await _database.getAllSessions();
        return sessions.map((s) => {
          'id': s.id,
          // 关键：确保时间被正确转换为 UTC 后再上传
          // 因为 Drift 读取的时间被解释为本地时间，需要先转回 UTC
          'start_time': DateTimeUtils.toUtc(s.startTime).toIso8601String(),
          'created_at': DateTimeUtils.toUtc(s.createdAt).toIso8601String(),
          'body_part_ids': s.bodyPartIds,
        }).toList();
      case 'exercise_records':
        final records = await _database.getAllExerciseRecordsIncludingDeleted();
        return records.map((r) => {
          'id': r.id,
          'session_id': r.sessionId,
          'exercise_id': r.exerciseId,
          'is_deleted': r.isDeleted,
        }).toList();
      case 'set_records':
        final sets = await (_database.select(_database.setRecords)).get();
        return sets.map((s) => {
          'id': s.id,
          'exercise_record_id': s.exerciseRecordId,
          'weight': s.weight,
          'reps': s.reps,
          'order_index': s.orderIndex,
        }).toList();
      case 'training_plans':
        final plans = await _database.getAllPlans();
        return plans.map((p) => {
          'id': p.id,
          'name': p.name,
          'cycle_length_days': p.cycleLengthDays,
          'created_at': p.createdAt.toIso8601String(),
        }).toList();
      case 'plan_items':
         final items = await (_database.select(_database.planItems)).get();
         return items.map((i) => {
           'id': i.id,
           'plan_id': i.planId,
           'day_index': i.dayIndex,
           'body_part_ids': i.bodyPartIds,
         }).toList();
      default:
        return [];
    }
  }

  /// Update local table data from cloud
  Future<void> _updateLocalTableData(String tableName, Map<String, dynamic> cloudData) async {
    try {
      switch (tableName) {
        case 'body_parts':
          await _database.into(_database.bodyParts).insert(
            BodyPartsCompanion(
              id: drift.Value(cloudData['id']),
              name: drift.Value(cloudData['name']),
              createdAt: drift.Value(DateTime.parse(cloudData['created_at'])),
              isDeleted: drift.Value(cloudData['is_deleted'] ?? false),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
          break;
        case 'exercises':
          // Handle both new body_part_ids and old body_part_id for backward compatibility
          final bodyPartIdsData = cloudData['body_part_ids'] ?? cloudData['body_part_id'];
          String bodyPartIdsStr = '[]';
          if (bodyPartIdsData != null) {
            if (bodyPartIdsData is String) {
              // If it's the new format (JSON array string), use it directly
              if (bodyPartIdsData.startsWith('[')) {
                bodyPartIdsStr = bodyPartIdsData;
              } else {
                // Old single ID format - convert to JSON array
                bodyPartIdsStr = '["$bodyPartIdsData"]';
              }
            } else if (bodyPartIdsData is List) {
              bodyPartIdsStr = bodyPartIdsData.toString();
            }
          }
          await _database.into(_database.exercises).insert(
            ExercisesCompanion(
              id: drift.Value(cloudData['id']),
              name: drift.Value(cloudData['name']),
              bodyPartIds: drift.Value(bodyPartIdsStr),
              createdAt: drift.Value(DateTime.parse(cloudData['created_at'])),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
          break;
        case 'workout_sessions':
          await _database.into(_database.workoutSessions).insert(
            WorkoutSessionsCompanion(
              id: drift.Value(cloudData['id']),
              startTime: drift.Value(DateTime.parse(cloudData['start_time'])),
              createdAt: drift.Value(DateTime.parse(cloudData['created_at'])),
              bodyPartIds: drift.Value(cloudData['body_part_ids'] ?? ''),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
          break;
        case 'exercise_records':
          await _database.into(_database.exerciseRecords).insert(
            ExerciseRecordsCompanion(
              id: drift.Value(cloudData['id']),
              sessionId: drift.Value(cloudData['session_id']),
              exerciseId: drift.Value(cloudData['exercise_id']),
              isDeleted: drift.Value(cloudData['is_deleted'] ?? false),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
          break;
        case 'set_records':
          await _database.into(_database.setRecords).insert(
            SetRecordsCompanion(
              id: drift.Value(cloudData['id']),
              exerciseRecordId: drift.Value(cloudData['exercise_record_id']),
              weight: drift.Value((cloudData['weight'] as num).toDouble()),
              reps: drift.Value((cloudData['reps'] as num).toInt()),
              orderIndex: drift.Value((cloudData['order_index'] as num).toInt()),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
          break;
        case 'training_plans':
          await _database.into(_database.trainingPlans).insert(
            TrainingPlansCompanion(
              id: drift.Value(cloudData['id']),
              name: drift.Value(cloudData['name']),
              cycleLengthDays: drift.Value((cloudData['cycle_length_days'] as num).toInt()),
              createdAt: drift.Value(DateTime.parse(cloudData['created_at'])),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
          break;
        case 'plan_items':
          await _database.into(_database.planItems).insert(
            PlanItemsCompanion(
              id: drift.Value(cloudData['id']),
              planId: drift.Value(cloudData['plan_id']),
              dayIndex: drift.Value((cloudData['day_index'] as num).toInt()),
              bodyPartIds: drift.Value(cloudData['body_part_ids'] ?? ''),
            ),
            mode: drift.InsertMode.insertOrReplace,
          );
          break;
      }
    } catch (e) {
      debugPrint('Error updating local table $tableName: $e');
    }
  }
}
