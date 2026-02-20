/// 云同步服务接口（预留）
abstract class SyncService {
  Future<void> uploadData();
  Future<void> downloadData();
}
