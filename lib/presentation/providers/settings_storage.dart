import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 设置存储服务
/// 封装 SharedPreferences 的读取/写入操作，用于持久化保存应用设置
class SettingsStorage {
  static SharedPreferences? _prefs;

  // Storage keys
  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  static const String _notificationEnabledKey = 'notification_enabled';
  static const String _reminderEnabledKey = 'reminder_enabled';

  /// 初始化 SharedPreferences
  /// 必须在应用启动时调用
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 获取 SharedPreferences 实例
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('SettingsStorage not initialized. Call SettingsStorage.init() first.');
    }
    return _prefs!;
  }

  // ===== Theme Mode =====

  /// 获取保存的主题模式
  static ThemeMode getThemeMode() {
    final value = prefs.getString(_themeModeKey);
    if (value == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  /// 保存主题模式
  static Future<bool> setThemeMode(ThemeMode mode) {
    return prefs.setString(_themeModeKey, mode.name);
  }

  // ===== Locale =====

  /// 获取保存的语言设置
  static String getLocale() {
    return prefs.getString(_localeKey) ?? 'en';
  }

  /// 保存语言设置
  static Future<bool> setLocale(String locale) {
    return prefs.setString(_localeKey, locale);
  }

  // ===== Notification =====

  /// 获取通知开关状态
  static bool getNotificationEnabled() {
    return prefs.getBool(_notificationEnabledKey) ?? false;
  }

  /// 保存通知开关状态
  static Future<bool> setNotificationEnabled(bool enabled) {
    return prefs.setBool(_notificationEnabledKey, enabled);
  }

  // ===== Reminder =====

  /// 获取训练提醒开关状态
  static bool getReminderEnabled() {
    return prefs.getBool(_reminderEnabledKey) ?? false;
  }

  /// 保存训练提醒开关状态
  static Future<bool> setReminderEnabled(bool enabled) {
    return prefs.setBool(_reminderEnabledKey, enabled);
  }

  // ===== Body Weight (Optional) =====

  /// Storage key for body weight
  static const String _bodyWeightKey = 'body_weight';

  /// 获取保存的体重（可选，用于相对容量计算）
  /// 返回 null 表示用户未设置体重
  static double? getBodyWeight() {
    return prefs.getDouble(_bodyWeightKey);
  }

  /// 保存体重
  /// 如果 weight 为 null，则清除体重数据
  static Future<bool> setBodyWeight(double? weight) {
    if (weight == null) {
      return prefs.remove(_bodyWeightKey);
    }
    return prefs.setDouble(_bodyWeightKey, weight);
  }

  // ===== Active Preset Plan (for execution tracking) =====

  /// Storage keys for active preset plan execution
  static const String _activePresetPlanKey = 'active_preset_plan';
  static const String _activePresetDayIndexKey = 'active_preset_day_index';

  /// Get the currently executing preset plan name (null if none)
  static String? getActivePresetPlan() {
    return prefs.getString(_activePresetPlanKey);
  }

  /// Set the currently executing preset plan
  static Future<bool> setActivePresetPlan(String? planName, int? dayIndex) async {
    if (planName == null) {
      await prefs.remove(_activePresetPlanKey);
      await prefs.remove(_activePresetDayIndexKey);
      return true;
    }
    await prefs.setString(_activePresetPlanKey, planName);
    if (dayIndex != null) {
      await prefs.setInt(_activePresetDayIndexKey, dayIndex);
    }
    return true;
  }

  /// Get the current day index for preset plan
  static int getActivePresetDayIndex() {
    return prefs.getInt(_activePresetDayIndexKey) ?? 1;
  }

  // ===== Preset Plan Last Executed Time (for sorting) =====

  /// Prefix for preset plan executed time storage keys
  static const String _presetExecutedPrefix = 'preset_executed_';

  /// Get the last executed time for all preset plans
  static Map<String, DateTime> getLastExecutedPresetPlans() {
    final Map<String, DateTime> result = {};
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(_presetExecutedPrefix)) {
        final planName = key.substring(_presetExecutedPrefix.length);
        final timestamp = prefs.getInt(key);
        if (timestamp != null) {
          result[planName] = DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
      }
    }
    return result;
  }

  /// Update the last executed time for a preset plan
  static Future<void> updatePresetPlanExecutedTime(String planName) async {
    await prefs.setInt(
      '$_presetExecutedPrefix$planName',
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
