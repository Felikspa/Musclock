import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../sync_service_impl.dart';

/// 同步状态
enum SyncStatusState {
  idle,
  syncing,
  success,
  error,
}

/// 同步状态数据
class SyncState {
  final SyncStatusState status;
  final int uploadedCount;
  final int downloadedCount;
  final DateTime? lastSyncTime;
  final String? errorMessage;

  const SyncState({
    this.status = SyncStatusState.idle,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.lastSyncTime,
    this.errorMessage,
  });

  SyncState copyWith({
    SyncStatusState? status,
    int? uploadedCount,
    int? downloadedCount,
    DateTime? lastSyncTime,
    String? errorMessage,
  }) {
    return SyncState(
      status: status ?? this.status,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 同步状态管理
class SyncStateNotifier extends StateNotifier<SyncState> {
  final CloudSyncService _syncService;

  SyncStateNotifier(this._syncService) : super(const SyncState());

  /// 获取上次同步时间
  Future<void> loadLastSyncTime() async {
    final metadata = await _syncService.getLastSyncMetadata();
    if (metadata != null) {
      state = state.copyWith(lastSyncTime: metadata.lastSyncTime);
    }
  }

  /// 执行完整同步
  Future<void> syncAll() async {
    state = state.copyWith(status: SyncStatusState.syncing);
    
    try {
      final result = await _syncService.syncAll();
      
      if (result.success) {
        state = state.copyWith(
          status: SyncStatusState.success,
          uploadedCount: result.uploadedCount,
          downloadedCount: result.downloadedCount,
          lastSyncTime: result.syncTime,
        );
      } else {
        state = state.copyWith(
          status: SyncStatusState.error,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: SyncStatusState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 仅上传
  Future<void> upload() async {
    state = state.copyWith(status: SyncStatusState.syncing);
    
    try {
      final result = await _syncService.uploadData();
      
      if (result.success) {
        state = state.copyWith(
          status: SyncStatusState.success,
          uploadedCount: result.uploadedCount,
          lastSyncTime: result.syncTime,
        );
      } else {
        state = state.copyWith(
          status: SyncStatusState.error,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: SyncStatusState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 仅下载
  Future<void> download() async {
    state = state.copyWith(status: SyncStatusState.syncing);
    
    try {
      final result = await _syncService.downloadData();
      
      if (result.success) {
        state = state.copyWith(
          status: SyncStatusState.success,
          downloadedCount: result.downloadedCount,
          lastSyncTime: result.syncTime,
        );
      } else {
        state = state.copyWith(
          status: SyncStatusState.error,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: SyncStatusState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(
      status: SyncStatusState.idle,
      errorMessage: null,
    );
  }
}
