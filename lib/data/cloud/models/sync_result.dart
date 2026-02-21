/// 同步结果模型
class SyncResult {
  final bool success;
  final int uploadedCount;
  final int downloadedCount;
  final int conflictsResolved;
  final String? errorMessage;
  final DateTime syncTime;

  SyncResult({
    required this.success,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictsResolved = 0,
    this.errorMessage,
    DateTime? syncTime,
  }) : syncTime = syncTime ?? DateTime.now();

  factory SyncResult.success({
    int uploadedCount = 0,
    int downloadedCount = 0,
    int conflictsResolved = 0,
  }) {
    return SyncResult(
      success: true,
      uploadedCount: uploadedCount,
      downloadedCount: downloadedCount,
      conflictsResolved: conflictsResolved,
    );
  }

  factory SyncResult.failure(String errorMessage) {
    return SyncResult(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// 同步状态枚举
enum SyncState {
  idle,
  syncing,
  success,
  error,
}

/// 同步元数据
class SyncMetadata {
  final String? userId;
  final DateTime? lastSyncTime;
  final int syncVersion;

  SyncMetadata({
    this.userId,
    this.lastSyncTime,
    this.syncVersion = 1,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'last_sync_time': lastSyncTime?.toIso8601String(),
    'sync_version': syncVersion,
  };

  factory SyncMetadata.fromJson(Map<String, dynamic> json) {
    return SyncMetadata(
      userId: json['user_id'] as String?,
      lastSyncTime: json['last_sync_time'] != null 
          ? DateTime.tryParse(json['last_sync_time'].toString())
          : null,
      syncVersion: json['sync_version'] as int? ?? 1,
    );
  }
}
