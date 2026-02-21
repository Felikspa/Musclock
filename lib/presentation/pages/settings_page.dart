import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Theme Settings
          _SettingsSection(
            title: l10n.theme,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(l10n.light),
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state = value!;
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.dark),
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state = value!;
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.system),
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state = value!;
                },
              ),
            ],
          ),

          // Language Settings
          _SettingsSection(
            title: l10n.language,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: locale,
                onChanged: (value) {
                  ref.read(localeProvider.notifier).state = value!;
                },
              ),
              RadioListTile<String>(
                title: const Text('中文'),
                value: 'zh',
                groupValue: locale,
                onChanged: (value) {
                  ref.read(localeProvider.notifier).state = value!;
                },
              ),
            ],
          ),

          // Data Management
          _SettingsSection(
            title: l10n.settings,
            children: [
              ListTile(
                leading: const Icon(Icons.file_download),
                title: Text(l10n.exportData),
                subtitle: Text(l10n.exportAsJson),
                onTap: () => _exportData(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: Text(l10n.backupData),
                subtitle: Text(l10n.createBackupFile),
                onTap: () => _backupData(context, ref),
              ),
            ],
          ),

          // Cloud Sync (Note: Requires configuration with MinApp credentials)
          // To enable: Uncomment and configure the providers in providers.dart
          _SettingsSection(
            title: l10n.cloudSync,
            children: [
              // Placeholder for cloud sync functionality
              // Uncomment when cloud providers are configured:
              // Consumer(builder: (context, ref, _) {
              //   final authState = ref.watch(authStateProvider);
              //   if (authState.status == AuthStatus.authenticated) {
              //     return Column(children: [
              //       ListTile(
              //         leading: const Icon(Icons.cloud_done),
              //         title: Text(l10n.loggedInAs),
              //         subtitle: Text(authState.user?.email ?? ''),
              //       ),
              //       ListTile(
              //         leading: const Icon(Icons.sync),
              //         title: Text(l10n.syncNow),
              //         onTap: () => ref.read(syncStateProvider.notifier).syncAll(),
              //       ),
              //       ListTile(
              //         leading: const Icon(Icons.logout),
              //         title: Text(l10n.logout),
              //         onTap: () => ref.read(authStateProvider.notifier).logout(),
              //       ),
              //     ]);
              //   }
              //   return Column(children: [
              //     ListTile(
              //       leading: const Icon(Icons.cloud_off),
              //       title: Text(l10n.notLoggedIn),
              //     ),
              //     ListTile(
              //       leading: const Icon(Icons.login),
              //       title: Text(l10n.login),
              //       onTap: () => Navigator.pushNamed(context, '/login'),
              //     ),
              //   ]);
              // }),
              ListTile(
                leading: const Icon(Icons.cloud_off),
                title: Text(l10n.notLoggedIn),
                subtitle: const Text('Configure MinApp credentials to enable'),
              ),
              ListTile(
                leading: const Icon(Icons.login),
                title: Text(l10n.login),
                onTap: () => _showLoginDialog(context),
              ),
            ],
          ),

          // About
          _SettingsSection(
            title: l10n.about,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Muscle Clock'),
                subtitle: Text('${l10n.version} 1.0.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final exportService = ref.read(exportServiceProvider);
      final jsonData = await exportService.exportToJson();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dataExported),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Log for now - in production would save/share the file
      print('Export data length: ${jsonData.length} characters');
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

  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final backupService = ref.read(backupServiceProvider);
      final file = await backupService.createBackup();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.dataBackup}: ${file.path}'),
            backgroundColor: Colors.green,
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

  void _showLoginDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cloudSync),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'To enable cloud sync, you need to:\n\n'
              '1. Configure your MinApp ClientID and Secret in providers.dart\n'
              '2. Create the required data tables in MinApp dashboard\n'
              '3. Rebuild the app\n\n'
              'See PROJECT_TRACKER.md for detailed instructions.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
