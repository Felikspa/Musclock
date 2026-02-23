import 'package:intl/intl.dart';

/// 时间格式化工具类
/// 统一处理时间的显示和转换，确保时区一致性
class DateTimeUtils {
  DateTimeUtils._();

  /// 从数据库读取 DateTime 后转换为正确的 UTC 时间
  /// Drift 数据库读取时默认将 Unix timestamp 解释为本地时间
  /// 这个方法确保时间被正确识别为 UTC
  static DateTime fromDatabase(DateTime dateTime) {
    // 如果时间没有 isUtc 标记（即 Drift 读取的本地时间）
    // 我们需要将其视为 UTC 并转换
    if (!dateTime.isUtc) {
      // 将时间作为 UTC 解释，然后转换为本地时间显示
      return dateTime.toUtc();
    }
    return dateTime;
  }

  /// 将 DateTime 转换为本地时间后显示
  /// 这是处理时间显示的核心方法，确保 UTC 时间正确转换为本地时区
  static DateTime toLocalTime(DateTime dateTime) {
    // 首先确保从数据库读取的时间被正确处理
    final normalized = fromDatabase(dateTime);
    // 如果是 UTC 时间，toLocal() 会正确转换为本地时间
    // 如果已经是本地时间，toLocal() 不会有任何效果
    return normalized.toLocal();
  }

  /// 格式化时间为 HH:mm 格式
  /// 自动将 UTC 时间转换为本地时间后再格式化
  static String formatTime(DateTime dateTime) {
    final localTime = toLocalTime(dateTime);
    return DateFormat.Hm().format(localTime);
  }

  /// 格式化时间为完整日期时间格式
  /// 用于详细记录显示
  static String formatDateTime(DateTime dateTime) {
    final localTime = toLocalTime(dateTime);
    return DateFormat('yyyy-MM-dd HH:mm').format(localTime);
  }

  /// 格式化日期为 yyyy-MM-dd 格式
  static String formatDate(DateTime dateTime) {
    final localTime = toLocalTime(dateTime);
    return DateFormat('yyyy-MM-dd').format(localTime);
  }

  /// 格式化日期为本地化格式（如 2月23日）
  static String formatDateLocalized(DateTime dateTime, String locale) {
    final localTime = toLocalTime(dateTime);
    if (locale == 'zh') {
      return DateFormat('M月d日').format(localTime);
    }
    return DateFormat('MMM d').format(localTime);
  }

  /// 检查两个 DateTime 是否在同一天（使用本地时区）
  static bool isSameDay(DateTime a, DateTime b) {
    final localA = toLocalTime(a);
    final localB = toLocalTime(b);
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }

  /// 获取一天的开始时间（本地时区）
  static DateTime getStartOfDay(DateTime dateTime) {
    final local = toLocalTime(dateTime);
    return DateTime(local.year, local.month, local.day);
  }

  /// 获取一天的结束时间（本地时区）
  static DateTime getEndOfDay(DateTime dateTime) {
    final local = toLocalTime(dateTime);
    return DateTime(local.year, local.month, local.day, 23, 59, 59, 999);
  }

  /// 将本地时间转换为 UTC 时间存储
  /// 仅在需要明确存储为 UTC 时使用
  static DateTime toUtc(DateTime dateTime) {
    return dateTime.toUtc();
  }
}
