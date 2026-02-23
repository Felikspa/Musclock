import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/appflowy_theme.dart';

/// Account settings content
class AccountSettingsContent extends ConsumerWidget {
  const AccountSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsBody(
      title: 'Account',
      description: 'Manage your account settings',
      children: [
        SettingsCategory(
          title: 'Profile',
          children: [
            _buildInfoTile(
              context,
              icon: Icons.info_outline,
              title: 'Muscle Clock',
              subtitle: 'Version 1.3.0',
              isDark: isDark,
            ),
            _buildInfoTile(
              context,
              icon: Icons.fitness_center,
              title: 'Fitness Tracker',
              subtitle: 'Track your training progress',
              isDark: isDark,
            ),
          ],
        ),
        const SettingsCategorySpacer(),
        SettingsCategory(
          title: 'About',
          children: [
            _buildInfoTile(
              context,
              icon: Icons.code,
              title: 'Built with Flutter',
              subtitle: 'Cross-platform framework',
              isDark: isDark,
            ),
            _buildInfoTile(
              context,
              icon: Icons.storage,
              title: 'Local Storage',
              subtitle: 'SQLite database',
              isDark: isDark,
            ),
          ],
        ),
      ],
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
        ],
      ),
    );
  }
}
