import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/appflowy_theme.dart';
import '../../providers/providers.dart';
import '../../../data/cloud/providers/auth_state.dart';
import '../../../data/cloud/providers/sync_state.dart';

/// Cloud settings content
class CloudSettingsContent extends ConsumerWidget {
  const CloudSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final syncState = ref.watch(syncStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsBody(
      title: l10n.cloudSync,
      description: 'Manage cloud synchronization',
      children: [
        if (authState.status == AuthStatus.authenticated)
          SettingsCategory(
            title: 'Account',
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.cloud_done_outlined,
                title: l10n.loggedInAs,
                subtitle: authState.user?.email ?? '',
                isDark: isDark,
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.sync,
                title: l10n.syncNow,
                subtitle: syncState.status == SyncStatusState.syncing
                    ? l10n.syncing
                    : '',
                isDark: isDark,
                onTap: syncState.status == SyncStatusState.syncing
                    ? () {}
                    : () async {
                        await ref.read(syncStateProvider.notifier).syncAll();
                        // Get the updated sync state after sync completes
                        final newState = ref.read(syncStateProvider);
                        if (!context.mounted) return;

                        if (newState.status == SyncStatusState.success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${l10n.syncSuccess}\n'
                                '${l10n.uploaded}: ${newState.uploadedCount} | '
                                '${l10n.downloaded}: ${newState.downloadedCount}',
                              ),
                              backgroundColor: MusclockBrandColors.primary,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else if (newState.status == SyncStatusState.error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${l10n.syncFailed}: ${newState.errorMessage}',
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.logout,
                title: l10n.logout,
                subtitle: '',
                isDark: isDark,
                onTap: () => ref.read(authStateProvider.notifier).logout(),
              ),
            ],
          )
        else
          SettingsCategory(
            title: 'Account',
            children: [
              _buildSettingsTile(
                context,
                icon: Icons.cloud_off_outlined,
                title: l10n.notLoggedIn,
                subtitle: '',
                isDark: isDark,
                onTap: CloudConfig.isConfigured
                    ? () => Navigator.pushNamed(context, '/login')
                    : () {},
              ),
              if (CloudConfig.isConfigured)
                _buildSettingsTile(
                  context,
                  icon: Icons.login,
                  title: l10n.login,
                  subtitle: '',
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/login'),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
}
