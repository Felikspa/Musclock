import '../../data/database/database.dart';

class CalculateVolumeUseCase {
  final AppDatabase _db;

  CalculateVolumeUseCase(this._db);

  /// 计算单组训练量
  double calculateSetVolume(double weight, int reps) {
    return weight * reps;
  }

  /// 计算单个动作的训练量
  Future<double> getExerciseVolume(String exerciseRecordId) async {
    final sets = await _db.getSetsByExerciseRecord(exerciseRecordId);
    double totalVolume = 0;
    for (final set in sets) {
      totalVolume += calculateSetVolume(set.weight, set.reps);
    }
    return totalVolume;
  }

  /// 计算单个Session的训练量
  Future<double> getSessionVolume(String sessionId) async {
    final records = await _db.getRecordsBySession(sessionId);
    double totalVolume = 0;

    for (final record in records) {
      totalVolume += await getExerciseVolume(record.id);
    }

    return totalVolume;
  }

  /// 获取每日训练量（用于Heatmap）
  Future<Map<DateTime, double>> getDailyVolumes() async {
    return await _db.getDailyVolumes();
  }

  /// 获取所有Session的训练量
  Future<Map<String, double>> getAllSessionVolumes() async {
    final sessions = await _db.getAllSessions();
    final Map<String, double> volumes = {};

    for (final session in sessions) {
      volumes[session.id] = await getSessionVolume(session.id);
    }

    return volumes;
  }

  /// 获取总训练量
  Future<double> getTotalVolume() async {
    final volumes = await getAllSessionVolumes();
    double total = 0;
    for (final volume in volumes.values) {
      total += volume;
    }
    return total;
  }

  /// 获取某个BodyPart的总训练量
  Future<double> getBodyPartVolume(String bodyPartId) async {
    final sessions = await _db.getSessionsByBodyPart(bodyPartId);
    double totalVolume = 0;

    for (final session in sessions) {
      totalVolume += await getSessionVolume(session.id);
    }

    return totalVolume;
  }

  /// 标准化训练量（用于颜色映射）
  double normalizeVolume(double volume, double maxVolume) {
    if (maxVolume == 0) return 0;
    return (volume / maxVolume).clamp(0.0, 1.0);
  }

  /// 获取颜色强度
  int getColorIntensity(double volume, double maxVolume) {
    final normalized = normalizeVolume(volume, maxVolume);
    return (normalized * 255).toInt();
  }
}
