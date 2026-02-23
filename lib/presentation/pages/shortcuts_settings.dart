import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_ui/appflowy_ui.dart';

/// Shortcuts settings content
class ShortcutsSettingsContent extends ConsumerWidget {
  const ShortcutsSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsBody(
      title: 'Shortcuts',
      description: 'Keyboard shortcuts for quick actions',
      children: [
        SettingsCategory(
          title: 'General',
          children: [
            _buildShortcutTile(
              context,
              icon: Icons.add_circle_outline,
              title: 'Add Exercise',
              shortcut: 'Ctrl + E',
              isDark: isDark,
            ),
            _buildShortcutTile(
              context,
              icon: Icons.play_arrow,
              title: 'Start Workout',
              shortcut: 'Ctrl + S',
              isDark: isDark,
            ),
            _buildShortcutTile(
              context,
              icon: Icons.stop,
              title: 'End Workout',
              shortcut: 'Ctrl + E',
              isDark: isDark,
            ),
          ],
        ),
        const SettingsCategorySpacer(),
        SettingsCategory(
          title: 'Navigation',
          children: [
            _buildShortcutTile(
              context,
              icon: Icons.calendar_today,
              title: 'Calendar View',
              shortcut: 'Ctrl + 1',
              isDark: isDark,
            ),
            _buildShortcutTile(
              context,
              icon: Icons.fitness_center,
              title: 'Today View',
              shortcut: 'Ctrl + 2',
              isDark: isDark,
            ),
            _buildShortcutTile(
              context,
              icon: Icons.analytics,
              title: 'Analysis View',
              shortcut: 'Ctrl + 3',
              isDark: isDark,
            ),
            _buildShortcutTile(
              context,
              icon: Icons.event_note,
              title: 'Plan View',
              shortcut: 'Ctrl + 4',
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String shortcut,
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
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
            child: Text(
              shortcut,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
