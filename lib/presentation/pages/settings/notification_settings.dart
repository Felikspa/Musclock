import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/settings_storage.dart';

/// Notification settings StateNotifier with persistence
class NotificationEnabledNotifier extends StateNotifier<bool> {
  NotificationEnabledNotifier() : super(SettingsStorage.getNotificationEnabled());

  void setEnabled(bool enabled) {
    state = enabled;
    SettingsStorage.setNotificationEnabled(enabled);
  }
}

class ReminderEnabledNotifier extends StateNotifier<bool> {
  ReminderEnabledNotifier() : super(SettingsStorage.getReminderEnabled());

  void setEnabled(bool enabled) {
    state = enabled;
    SettingsStorage.setReminderEnabled(enabled);
  }
}

/// Notification settings providers
final notificationEnabledProvider = StateNotifierProvider<NotificationEnabledNotifier, bool>((ref) {
  return NotificationEnabledNotifier();
});

final reminderEnabledProvider = StateNotifierProvider<ReminderEnabledNotifier, bool>((ref) {
  return ReminderEnabledNotifier();
});

/// Notification settings content
class NotificationSettingsContent extends ConsumerWidget {
  const NotificationSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationEnabled = ref.watch(notificationEnabledProvider);
    final reminderEnabled = ref.watch(reminderEnabledProvider);

    return SettingsBody(
      title: l10n.notifications,
      description: 'Manage notification preferences',
      children: [
        SettingsCategory(
          title: 'General',
          children: [
            _buildSwitchTile(
              context,
              ref,
              icon: Icons.notifications_outlined,
              title: l10n.notifications,
              subtitle: 'Receive push notifications',
              value: notificationEnabled,
              onChanged: (value) {
                ref.read(notificationEnabledProvider.notifier).setEnabled(value);
              },
              isDark: isDark,
            ),
            _buildSwitchTile(
              context,
              ref,
              icon: Icons.alarm_outlined,
              title: 'Training Reminder',
              subtitle: 'Get reminded to train',
              value: reminderEnabled,
              onChanged: (value) {
                ref.read(reminderEnabledProvider.notifier).setEnabled(value);
              },
              isDark: isDark,
            ),
          ],
        ),
        const SettingsCategorySpacer(),
        if (notificationEnabled)
          SettingsCategory(
            title: 'Types',
            children: [
              _buildInfoTile(
                context,
                icon: Icons.fitness_center,
                title: 'Workout Reminders',
                subtitle: 'Training schedule notifications',
                isDark: isDark,
              ),
              _buildInfoTile(
                context,
                icon: Icons.analytics_outlined,
                title: 'Analysis Reports',
                subtitle: 'Weekly training summary',
                isDark: isDark,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
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
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
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
          Icon(
            Icons.chevron_right,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ],
      ),
    );
  }
}
