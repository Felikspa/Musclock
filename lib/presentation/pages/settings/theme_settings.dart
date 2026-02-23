import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../../core/theme/appflowy_theme.dart';

/// Theme settings content
class ThemeSettingsContent extends ConsumerWidget {
  const ThemeSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsBody(
      title: l10n.theme,
      description: 'Choose your preferred appearance',
      children: [
        SettingsCategory(
          title: 'Appearance',
          children: [
            _buildThemeOption(
              context,
              ref,
              l10n.light,
              ThemeMode.light,
              currentMode,
              isDark,
            ),
            _buildThemeOption(
              context,
              ref,
              l10n.dark,
              ThemeMode.dark,
              currentMode,
              isDark,
            ),
            _buildThemeOption(
              context,
              ref,
              l10n.system,
              ThemeMode.system,
              currentMode,
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    ThemeMode mode,
    ThemeMode currentMode,
    bool isDark,
  ) {
    final isSelected = currentMode == mode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : (isDark ? Colors.white38 : Colors.black38),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                      ),
                    )
                  : null,
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
}
