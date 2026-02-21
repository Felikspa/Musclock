/// 云同步服务接口（预留）
/// Currently not used - reserved for future cloud sync implementation
/// The local Repository calls through interfaces without directly depending on this implementation.
/// To use this, implement the interface and inject via a Provider.
abstract class SyncService {
  Future<void> uploadData();
  Future<void> downloadData();
}
