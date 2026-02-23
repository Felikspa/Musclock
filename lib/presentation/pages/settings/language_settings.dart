import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/providers.dart';

/// Language settings content
class LanguageSettingsContent extends ConsumerWidget {
  const LanguageSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsBody(
      title: l10n.language,
      description: 'Select your preferred language',
      children: [
        SettingsCategory(
          title: 'Language',
          children: [
            _buildLanguageOption(
              context,
              ref,
              'English',
              'en',
              currentLocale,
              isDark,
            ),
            _buildLanguageOption(
              context,
              ref,
              '中文',
              'zh',
              currentLocale,
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    String locale,
    String currentLocale,
    bool isDark,
  ) {
    final isSelected = currentLocale == locale;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
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
