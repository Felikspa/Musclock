import '../../data/database/database.dart';

class CalculateRestDaysUseCase {
  final AppDatabase _db;

  CalculateRestDaysUseCase(this._db);

  /// 获取某个BodyPart的上次训练时间
  Future<DateTime?> getLastTrainedTime(String bodyPartId) async {
    final sessions = await _db.getSessionsByBodyPart(bodyPartId);
    if (sessions.isEmpty) return null;
    return sessions.first.startTime;
  }

  /// 计算某个BodyPart的休息天数
  Future<int> getRestDays(String bodyPartId) async {
    final lastTrained = await getLastTrainedTime(bodyPartId);
    if (lastTrained == null) return -1; // 从未训练

    final now = DateTime.now().toUtc();
    final restMinutes = now.difference(lastTrained).inMinutes;
    return (restMinutes / (24 * 60)).floor();
  }

  /// 获取所有部位的休息天数
  Future<Map<String, int>> getAllRestDays() async {
    final bodyParts = await _db.getAllBodyParts();
    final Map<String, int> restDaysMap = {};

    for (final bp in bodyParts) {
      restDaysMap[bp.id] = await getRestDays(bp.id);
    }

    return restDaysMap;
  }

  /// 格式化显示休息时间
  String formatRestTime(int restDays) {
    if (restDays < 0) return 'Never trained';
    if (restDays == 0) return 'Today';
    if (restDays == 1) return '1 day';
    return '$restDays days';
  }

  /// 获取详细休息时间（包含小时）
  Future<String> getDetailedRestTime(String bodyPartId) async {
    final lastTrained = await getLastTrainedTime(bodyPartId);
    if (lastTrained == null) return 'Never trained';

    final now = DateTime.now().toUtc();
    final restDuration = now.difference(lastTrained);
    final days = restDuration.inDays;
    final hours = restDuration.inHours % 24;

    if (days == 0) {
      return '$hours hours';
    } else if (hours == 0) {
      return '$days day${days > 1 ? 's' : ''}';
    } else {
      return '$days day${days > 1 ? 's' : ''} $hours hour${hours > 1 ? 's' : ''}';
    }
  }
}
