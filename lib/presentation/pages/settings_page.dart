import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../../data/cloud/providers/auth_state.dart';
import '../../data/cloud/providers/sync_state.dart';
import '../../core/theme/appflowy_theme.dart';
import 'settings/notification_settings.dart';

/// AppFlowy风格的设置页面
/// 通过顶部导航栏的"更多"按钮打开
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 获取背景色
    Color backgroundColor;
    Color cardColor;

    backgroundColor = isDark
        ? const Color(0xFF23262B)
        : Colors.white;
    cardColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          l10n.settings,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            // 使用 popUntil 返回到首页，避免黑屏问题
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== 主题设置 (Theme) =====
          _buildAppFlowyCard(
            context: context,
            isDark: isDark,
            cardColor: cardColor,
            title: l10n.theme,
            icon: Icons.palette_outlined,
            children: [
              _buildThemeOption(context, ref, l10n.light, ThemeMode.light, isDark),
              _buildThemeOption(context, ref, l10n.dark, ThemeMode.dark, isDark),
              _buildThemeOption(context, ref, l10n.system, ThemeMode.system, isDark),
            ],
          ),

          const SizedBox(height: 16),

          // ===== 语言设置 (Language) =====
          _buildAppFlowyCard(
            context: context,
            isDark: isDark,
            cardColor: cardColor,
            title: l10n.language,
            icon: Icons.language_outlined,
            children: [
              _buildLanguageOption(context, ref, 'English', 'en', isDark),
              _buildLanguageOption(context, ref, '中文', 'zh', isDark),
            ],
          ),

          const SizedBox(height: 16),

          // ===== 数据管理 (Data) =====
          _buildAppFlowyCard(
            context: context,
            isDark: isDark,
            cardColor: cardColor,
            title: 'Data',
            icon: Icons.storage_outlined,
            children: [
              _buildSettingsTile(
                context: context,
                ref: ref,
                icon: Icons.file_download_outlined,
                title: l10n.exportData,
                subtitle: l10n.exportAsJson,
                isDark: isDark,
                onTap: () => _exportData(context, ref),
              ),
              _buildSettingsTile(
                context: context,
                ref: ref,
                icon: Icons.backup_outlined,
                title: l10n.backupData,
                subtitle: l10n.createBackupFile,
                isDark: isDark,
                onTap: () => _backupData(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===== 通知设置 (Notifications) =====
          _buildAppFlowyCard(
            context: context,
            isDark: isDark,
            cardColor: cardColor,
            title: l10n.notifications,
            icon: Icons.notifications_outlined,
            children: [
              _buildNotificationTile(
                icon: Icons.notifications_outlined,
                title: l10n.notifications,
                subtitle: 'Receive push notifications',
                value: ref.watch(notificationEnabledProvider),
                isDark: isDark,
                onChanged: (value) {
                  ref.read(notificationEnabledProvider.notifier).setEnabled(value);
                },
              ),
              _buildNotificationTile(
                icon: Icons.alarm_outlined,
                title: 'Training Reminder',
                subtitle: 'Get reminded to train',
                value: ref.watch(reminderEnabledProvider),
                isDark: isDark,
                onChanged: (value) {
                  ref.read(reminderEnabledProvider.notifier).setEnabled(value);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ===== 云同步 (Cloud) =====
          _buildCloudSyncCard(context, ref, l10n, isDark, cardColor),

          const SizedBox(height: 16),

          // ===== 关于 (About) =====
          _buildAppFlowyCard(
            context: context,
            isDark: isDark,
            cardColor: cardColor,
            title: l10n.about,
            icon: Icons.info_outline,
            children: [
              _buildSettingsTile(
                context: context,
                ref: ref,
                icon: Icons.fitness_center,
                title: 'Muscle Clock',
                subtitle: '${l10n.version} 1.3.2',
                isDark: isDark,
                onTap: () => _showAboutDialog(context, isDark),
              ),
            ],
          ),

          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  /// 构建AppFlowy风格的卡片
  Widget _buildAppFlowyCard({
    required BuildContext context,
    required bool isDark,
    required Color cardColor,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // 卡片内容
          ...children,
        ],
      ),
    );
  }

  /// 构建主题选项
  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    ThemeMode mode,
    bool isDark,
  ) {
    final currentMode = ref.watch(themeModeProvider);
    final isSelected = currentMode == mode;

    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 20,
              color: isSelected
                  ? MusclockBrandColors.primary
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建语言选项
  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    String locale,
    bool isDark,
  ) {
    final currentLocale = ref.watch(localeProvider);
    final isSelected = currentLocale == locale;

    return InkWell(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 20,
              color: isSelected
                  ? MusclockBrandColors.primary
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建设置项
  Widget _buildSettingsTile({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建通知开关
  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: MusclockBrandColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建云同步卡片
  Widget _buildCloudSyncCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool isDark,
    Color cardColor,
  ) {
    final authState = ref.watch(authStateProvider);
    final syncState = ref.watch(syncStateProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  size: 18,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.cloudSync,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // 已登录状态
          if (isLoggedIn) ...[
            _buildSettingsTile(
              context: context,
              ref: ref,
              icon: Icons.cloud_done_outlined,
              title: l10n.loggedInAs,
              subtitle: authState.user?.email ?? '',
              isDark: isDark,
              onTap: () {},
            ),
            _buildSettingsTile(
              context: context,
              ref: ref,
              icon: Icons.sync,
              title: l10n.syncNow,
              subtitle: syncState.status == SyncStatusState.syncing ? l10n.syncing : '',
              isDark: isDark,
              onTap: syncState.status == SyncStatusState.syncing
                  ? () {}
                  : () async {
                      await ref.read(syncStateProvider.notifier).syncAll();
                    },
            ),
            _buildSettingsTile(
              context: context,
              ref: ref,
              icon: Icons.logout,
              title: l10n.logout,
              subtitle: '',
              isDark: isDark,
              onTap: () {
                ref.read(authStateProvider.notifier).logout();
              },
            ),
          ] else ...[
            // 未登录状态
            if (CloudConfig.isConfigured) ...[
              _buildSettingsTile(
                context: context,
                ref: ref,
                icon: Icons.cloud_off_outlined,
                title: l10n.notLoggedIn,
                subtitle: '',
                isDark: isDark,
                onTap: () {},
              ),
              _buildSettingsTile(
                context: context,
                ref: ref,
                icon: Icons.login,
                title: 'Sign in',
                subtitle: '',
                isDark: isDark,
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ] else ...[
              _buildSettingsTile(
                context: context,
                ref: ref,
                icon: Icons.cloud_off_outlined,
                title: l10n.notLoggedIn,
                subtitle: '',
                isDark: isDark,
                onTap: () {},
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: MusclockBrandColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Muscle Clock',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: Text(
          'Version 1.3.2\n\nA lightweight strength training tracker',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: MusclockBrandColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 导出数据
  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final exportService = ref.read(exportServiceProvider);
      await exportService.exportToJson();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dataExported),
            backgroundColor: MusclockBrandColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 备份数据
  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.createBackup();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dataBackup),
            backgroundColor: MusclockBrandColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
