import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/cloud/providers/auth_state.dart';
import '../../../presentation/providers/providers.dart';
import '../../pages/settings_page.dart' as settings;

/// Popover菜单组件 - 点击更多按钮时显示
/// 两栏布局：设置 + 账户/登录
class PopoverMenu extends ConsumerWidget {
  final VoidCallback onClose;

  const PopoverMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    // 使用AppFlowyThemeData
    AppFlowyThemeData? theme;
    try {
      theme = AppFlowyTheme.of(context);
    } catch (_) {
      // 如果没有AppFlowyTheme，使用Flutter主题色
    }
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 第1栏：设置
        _buildMenuItem(
          context: context,
          icon: Icons.settings_outlined,
          label: l10n.settings,
          isDark: isDark,
          onTap: () {
            // 关闭popover
            onClose();
            // 打开设置页面
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const settings.SettingsPage()),
            );
          },
        ),
        const SizedBox(height: 4),
        // 第2栏：账户/登录
        _buildAccountItem(
          context: context,
          authState: authState,
          isDark: isDark,
          theme: theme,
          l10n: l10n,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem({
    required BuildContext context,
    required AuthState authState,
    required bool isDark,
    AppFlowyThemeData? theme,
    required AppLocalizations l10n,
  }) {
    final isLoggedIn = authState.status == AuthStatus.authenticated;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () {
        onClose();
        if (isLoggedIn) {
          // 已登录：打开设置页面
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const settings.SettingsPage()),
          );
        } else {
          // 未登录：跳转到登录页面
          Navigator.pushNamed(context, '/login');
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // 头像或图标
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLoggedIn
                    ? primaryColor
                    : (isDark ? Colors.white24 : Colors.black12),
              ),
              child: Icon(
                isLoggedIn ? Icons.person : Icons.login,
                size: 18,
                color: isLoggedIn
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoggedIn
                        ? (authState.user?.email ?? l10n.account)
                        : l10n.login,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isLoggedIn ? FontWeight.w500 : FontWeight.normal,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isLoggedIn && authState.user?.email != null)
                    Text(
                      authState.user!.email!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (!isLoggedIn)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark ? Colors.white24 : Colors.black12,
              ),
          ],
        ),
      ),
    );
  }
}

/// 显示Popover菜单
void showPopoverMenu(BuildContext context, Offset position) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  // 关闭popover的回调
  void closePopover() {
    overlayEntry.remove();
  }

  overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        // 点击外部关闭
        Positioned.fill(
          child: GestureDetector(
            onTap: closePopover,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Popover内容
        Positioned(
          left: position.dx - 80,
          top: position.dy + 10,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 180,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2C2E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: PopoverMenu(onClose: closePopover),
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(overlayEntry);
}
