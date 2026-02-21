import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database.dart';
import 'minapp_client.dart';
import 'models/sync_result.dart';

/// Cloud sync service implementation
/// Uses merge strategy for data synchronization
class CloudSyncService {
  final MinAppClient _client;
  final AppDatabase _database;
  
  // Metadata storage key
  static const String _metadataKey = 'sync_metadata';
  final FlutterSecureStorage _storage;
  
  SyncMetadata? _lastSyncMetadata;
  
  // Table name mapping
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
    if (_lastSyncMetadata != null) {
      return _lastSyncMetadata;
    }
    
    final json = await _storage.read(key: _metadataKey);
    if (json != null) {
      try {
        _lastSyncMetadata = SyncMetadata.fromJson(
          Map<String, dynamic>.from(_parseJson(json)),
        );
      } catch (e) {
        debugPrint('Failed to parse sync metadata: $e');
      }
    }
    return _lastSyncMetadata;
  }

  /// Save sync metadata
  Future<void> _saveSyncMetadata(SyncMetadata metadata) async {
    _lastSyncMetadata = metadata;
    await _storage.write(
      key: _metadataKey,
      value: _encodeJson(metadata.toJson()),
    );
  }

  Map<String, dynamic> _parseJson(String json) {
    final result = <String, dynamic>{};
    final content = json.substring(1, json.length - 1);
    final pairs = content.split(', ');
    for (final pair in pairs) {
      final parts = pair.split(': ');
      if (parts.length == 2) {
        final key = parts[0].replaceAll('"', '');
        final value = parts[1].replaceAll('"', '');
        result[key] = value == 'null' ? null : value;
      }
    }
    return result;
  }

  String _encodeJson(Map<String, dynamic> map) {
    final entries = map.entries.map((e) => '"${e.key}": "${e.value}"').join(', ');
    return '{$entries}';
  }

  /// Perform full sync
  Future<SyncResult> syncAll() async {
    if (!_client.isLoggedIn) {
      return SyncResult.failure('User not logged in');
    }

    try {
      int uploaded = 0;
      int downloaded = 0;
      int conflicts = 0;

      // 1. Upload local data
      for (final entry in _tableNameMap.entries) {
        final result = await _syncTable(entry.key, entry.value);
        uploaded += result['uploaded'] ?? 0;
        downloaded += result['downloaded'] ?? 0;
        conflicts += result['conflicts'] ?? 0;
      }

      // 2. Update sync metadata
      final userId = await _client.getCurrentUserId();
      await _saveSyncMetadata(SyncMetadata(
        userId: userId,
        lastSyncTime: DateTime.now(),
        syncVersion: (_lastSyncMetadata?.syncVersion ?? 0) + 1,
      ));

      return SyncResult.success(
        uploadedCount: uploaded,
        downloadedCount: downloaded,
        conflictsResolved: conflicts,
      );
    } catch (e) {
      debugPrint('Sync error: $e');
      return SyncResult.failure(e.toString());
    }
  }

  /// Sync single table with merge strategy
  Future<Map<String, int>> _syncTable(String localTable, String cloudTable) async {
    int uploaded = 0;
    int downloaded = 0;
    int conflicts = 0;

    try {
      // 1. Get local data
      final localData = await _getLocalTableData(localTable);
      
      // 2. Get cloud data
      final cloudResult = await _client.queryTable(
        tableName: cloudTable,
        where: {'user_id': await _client.getCurrentUserId()},
      );
      final cloudData = {for (var r in cloudResult.records) r.id: r};

      // 3. Merge data
      for (final local in localData) {
        final localId = local['id'] as String;
        final localUpdatedAt = local['updated_at'] != null 
            ? DateTime.parse(local['updated_at'] as String)
            : DateTime.parse(local['created_at'] as String);

        if (cloudData.containsKey(localId)) {
          // Record exists, compare timestamps
          final cloud = cloudData[localId]!;
          final cloudUpdatedAt = cloud.updatedAt ?? cloud.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

          if (localUpdatedAt.isAfter(cloudUpdatedAt)) {
            // Local is newer, upload
            await _client.updateRecord(
              tableName: cloudTable,
              recordId: localId,
              data: _prepareCloudData(local),
            );
            uploaded++;
          } else if (localUpdatedAt.isBefore(cloudUpdatedAt)) {
            // Cloud is newer, download
            await _updateLocalTableData(localTable, cloud.data);
            downloaded++;
          }
          // Equal - ignore
        } else {
          // Doesn't exist in cloud, upload
          await _client.createRecord(
            tableName: cloudTable,
            data: _prepareCloudData(local),
          );
          uploaded++;
        }
      }

      // 4. Handle new cloud records (not in local)
      for (final cloud in cloudData.values) {
        final cloudId = cloud.id;
        final hasLocal = localData.any((l) => l['id'] == cloudId);
        if (!hasLocal) {
          await _updateLocalTableData(localTable, cloud.data);
          downloaded++;
        }
      }
    } catch (e) {
      debugPrint('Error syncing table $localTable: $e');
    }

    return {
      'uploaded': uploaded,
      'downloaded': downloaded,
      'conflicts': conflicts,
    };
  }

  /// Prepare data for cloud upload (add user_id)
  Map<String, dynamic> _prepareCloudData(Map<String, dynamic> localData) {
    final data = Map<String, dynamic>.from(localData);
    data['user_id'] = _client.getCurrentUserId();
    // Remove local timestamp, use cloud auto-generated
    data.remove('updated_at');
    return data;
  }

  /// Get local table data
  Future<List<Map<String, dynamic>>> _getLocalTableData(String tableName) async {
    switch (tableName) {
      case 'body_parts':
        final parts = await _database.getAllBodyParts();
        return parts.map((p) => {
          'id': p.id,
          'name': p.name,
          'created_at': p.createdAt.toIso8601String(),
          'updated_at': p.createdAt.toIso8601String(),
          'is_deleted': p.isDeleted,
        }).toList();
      case 'exercises':
        final exercises = await _database.getAllExercises();
        return exercises.map((e) => {
          'id': e.id,
          'name': e.name,
          'body_part_id': e.bodyPartId,
          'created_at': e.createdAt.toIso8601String(),
          'updated_at': e.createdAt.toIso8601String(),
        }).toList();
      case 'workout_sessions':
        final sessions = await _database.getAllSessions();
        return sessions.map((s) => {
          'id': s.id,
          'start_time': s.startTime.toIso8601String(),
          'created_at': s.createdAt.toIso8601String(),
          'body_part_ids': '',
          'updated_at': s.createdAt.toIso8601String(),
        }).toList();
      default:
        return [];
    }
  }

  /// Update local table data
  Future<void> _updateLocalTableData(String tableName, Map<String, dynamic> cloudData) async {
    // Implementation depends on table type
    // Needs coordination with local database layer
    debugPrint('Updating local table $tableName with cloud data: $cloudData');
  }

  /// Upload local data only
  Future<SyncResult> uploadData() async {
    if (!_client.isLoggedIn) {
      return SyncResult.failure('User not logged in');
    }

    try {
      int uploaded = 0;

      for (final entry in _tableNameMap.entries) {
        final localData = await _getLocalTableData(entry.key);
        
        for (final data in localData) {
          try {
            await _client.createRecord(
              tableName: entry.value,
              data: _prepareCloudData(data),
            );
            uploaded++;
          } catch (e) {
            // Record may already exist, try update
            try {
              await _client.updateRecord(
                tableName: entry.value,
                recordId: data['id'] as String,
                data: _prepareCloudData(data),
              );
              uploaded++;
            } catch (e2) {
              debugPrint('Failed to sync record ${data['id']}: $e2');
            }
          }
        }
      }

      // Update sync time
      final userId = await _client.getCurrentUserId();
      await _saveSyncMetadata(SyncMetadata(
        userId: userId,
        lastSyncTime: DateTime.now(),
        syncVersion: (_lastSyncMetadata?.syncVersion ?? 0) + 1,
      ));

      return SyncResult.success(uploadedCount: uploaded);
    } catch (e) {
      debugPrint('Upload error: $e');
      return SyncResult.failure(e.toString());
    }
  }

  /// Download cloud data only
  Future<SyncResult> downloadData() async {
    if (!_client.isLoggedIn) {
      return SyncResult.failure('User not logged in');
    }

    try {
      int downloaded = 0;

      for (final entry in _tableNameMap.entries) {
        final result = await _client.queryTable(
          tableName: entry.value,
          where: {'user_id': await _client.getCurrentUserId()},
        );

        for (final record in result.records) {
          await _updateLocalTableData(entry.key, record.data);
          downloaded++;
        }
      }

      // Update sync time
      final userId = await _client.getCurrentUserId();
      await _saveSyncMetadata(SyncMetadata(
        userId: userId,
        lastSyncTime: DateTime.now(),
        syncVersion: (_lastSyncMetadata?.syncVersion ?? 0) + 1,
      ));

      return SyncResult.success(downloadedCount: downloaded);
    } catch (e) {
      debugPrint('Download error: $e');
      return SyncResult.failure(e.toString());
    }
  }

  /// Incremental sync since last sync time
  Future<SyncResult> syncSince(DateTime? lastSyncTime) async {
    // Simplified: call full sync
    // Production needs to track record change timestamps
    return await syncAll();
  }
}
