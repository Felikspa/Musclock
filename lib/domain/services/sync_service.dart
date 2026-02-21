/// 云同步服务接口（预留）
/// Currently not used - reserved for future cloud sync implementation
/// The local Repository calls through interfaces without directly depending on this implementation.
/// To use this, implement the interface and inject via a Provider.
abstract class SyncService {
  /// 上传本地数据到云端
  Future<void> uploadData();
  
  /// 从云端下载数据到本地
  Future<void> downloadData();
  
  /// 执行完整同步（合并策略）
  Future<void> syncAll();
  
  /// 检查是否已登录
  bool get isLoggedIn;
  
  /// 获取上次同步时间
  Future<DateTime?> getLastSyncTime();
}
