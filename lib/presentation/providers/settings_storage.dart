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
}
