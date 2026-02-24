import '../../data/database/database.dart';
import '../../core/utils/date_time_utils.dart';

class CalculateFrequencyUseCase {
  final AppDatabase _db;

  CalculateFrequencyUseCase(this._db);

  /// 计算某个BodyPart的训练频率
  /// frequency = totalSessionsContainingBodyPart / totalDaysSinceFirstSession
  Future<double> getFrequency(String bodyPartId) async {
    final firstSession = await _db.getFirstSession();
    if (firstSession == null) return 0.0;

    final sessions = await _db.getSessionsByBodyPart(bodyPartId);
    if (sessions.isEmpty) return 0.0;

    final now = DateTimeUtils.nowUtc;
    final totalDays = now.difference(firstSession.startTime).inDays;
    if (totalDays == 0) return sessions.length.toDouble();

    return sessions.length / totalDays;
  }

  /// 获取每周训练频率
  Future<double> getWeeklyFrequency(String bodyPartId) async {
    final frequency = await getFrequency(bodyPartId);
    return frequency * 7;
  }

  /// 计算全局训练频率
  Future<double> getGlobalFrequency() async {
    final firstSession = await _db.getFirstSession();
    if (firstSession == null) return 0.0;

    final sessions = await _db.getAllSessions();
    if (sessions.isEmpty) return 0.0;

    final now = DateTimeUtils.nowUtc;
    final totalDays = now.difference(firstSession.startTime).inDays;
    if (totalDays == 0) return sessions.length.toDouble();

    return sessions.length / totalDays;
  }

  /// 获取全局每周训练频率
  Future<double> getGlobalWeeklyFrequency() async {
    final frequency = await getGlobalFrequency();
    return frequency * 7;
  }

  /// 获取所有部位的频率
  Future<Map<String, double>> getAllFrequencies() async {
    final bodyParts = await _db.getAllBodyParts();
    final Map<String, double> frequencies = {};

    for (final bp in bodyParts) {
      frequencies[bp.id] = await getFrequency(bp.id);
    }

    return frequencies;
  }
}
