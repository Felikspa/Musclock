import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../../data/cloud/providers/auth_state.dart';
import '../../../data/cloud/providers/sync_state.dart';
import '../../../core/theme/appflowy_theme.dart';
import 'theme_settings.dart';
import 'language_settings.dart';
import 'data_settings.dart';
import 'cloud_settings.dart';
import 'account_settings.dart';
import 'notification_settings.dart';

/// Settings dialog with AppFlowy-style dual-pane layout
class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  SettingsPage _currentPage = SettingsPage.theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Determine dialog width based on screen size
    final dialogWidth = isMobile ? screenWidth * 0.95 : 720.0;
    final sidebarWidth = isMobile ? 0.0 : 180.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF23262B)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Left sidebar - Settings menu
            if (!isMobile)
              SizedBox(
                width: sidebarWidth,
                child: SettingsMenu(
                  currentPage: _currentPage,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ),
            // Divider
            if (!isMobile)
              Container(
                width: 1,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white10
                    : Colors.black.withOpacity(0.05),
              ),
            // Right content area
            Expanded(
              child: _buildContent(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    switch (_currentPage) {
      case SettingsPage.theme:
        return const ThemeSettingsContent();
      case SettingsPage.language:
        return const LanguageSettingsContent();
      case SettingsPage.data:
        return const DataSettingsContent();
      case SettingsPage.cloud:
        return const CloudSettingsContent();
      case SettingsPage.account:
        return const AccountSettingsContent();
      case SettingsPage.notification:
        return const NotificationSettingsContent();
    }
  }
}

/// Show settings dialog
void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const SettingsDialog(),
  );
}
