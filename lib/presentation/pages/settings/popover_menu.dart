import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_ui/appflowy_ui.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/cloud/providers/auth_state.dart';
import '../../../data/cloud/providers/sync_state.dart';
import '../../../core/theme/appflowy_theme.dart';
import '../../providers/providers.dart';
import '../../pages/settings_page.dart' as settings;

/// Popover菜单组件 - 点击更多按钮时显示
/// 两栏布局：设置 + 账户/登录
class PopoverMenu extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const PopoverMenu({super.key, required this.onClose});

  @override
  ConsumerState<PopoverMenu> createState() => _PopoverMenuState();
}

class _PopoverMenuState extends ConsumerState<PopoverMenu> {
  
  @override
  Widget build(BuildContext context) {
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
          ref: ref,
          icon: Icons.settings_outlined,
          label: l10n.settings,
          isDark: isDark,
          onTap: () {
            // 关闭popover
            widget.onClose();
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
          onClose: widget.onClose,
        ),
        const SizedBox(height: 4),
        // 第3栏：云同步
        _buildMenuItem(
          context: context,
          ref: ref,
          icon: Icons.cloud_sync,
          label: l10n.cloudSync,
          isDark: isDark,
          onTap: () async {
            // 使用全局 ScaffoldMessengerKey 获取 Messenger
            // 这样即使在 Overlay 中也能正常显示 Snackbar
            final messenger = ref.read(scaffoldMessengerKeyProvider).currentState;
            if (messenger == null) return;
            
            // 显示"同步进行中"提示
            messenger.showSnackBar(
              SnackBar(
                content: Text(l10n.syncing),
                backgroundColor: MusclockBrandColors.primary,
                duration: const Duration(seconds: 2),
              ),
            );
            
            // 关闭popover
            widget.onClose();
            
            // 触发同步并等待完成
            await ref.read(syncStateProvider.notifier).syncAll();
            
            // 等待状态更新
            await Future.delayed(const Duration(milliseconds: 100));
            
            // 获取同步后的状态
            final syncState = ref.read(syncStateProvider);
            
            // 显示结果 SnackBar
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  syncState.status == SyncStatusState.success
                      ? '${l10n.syncSuccess}\n'
                        '${l10n.uploaded}: ${syncState.uploadedCount} | '
                        '${l10n.downloaded}: ${syncState.downloadedCount}'
                      : '${l10n.syncFailed}: ${syncState.errorMessage}',
                ),
                backgroundColor: syncState.status == SyncStatusState.success
                    ? MusclockBrandColors.primary
                    : Colors.red,
                duration: Duration(seconds: syncState.status == SyncStatusState.success ? 3 : 4),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required WidgetRef ref,
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
    required VoidCallback onClose,
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

  // 获取状态栏高度
  final mediaQuery = MediaQuery.of(context);
  final statusBarHeight = mediaQuery.padding.top;
  final screenWidth = mediaQuery.size.width;

  // Popover尺寸
  const popoverWidth = 260.0;
  const popoverRight = 12.0;
  const popoverTop = 60.0;

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
        // Popover内容 - 带动画
        _AnimatedPopover(
          closePopover: closePopover,
          popoverWidth: popoverWidth,
          popoverRight: popoverRight,
          popoverTop: popoverTop,
          statusBarHeight: statusBarHeight,
          screenWidth: screenWidth,
        ),
      ],
    ),
  );

  overlay.insert(overlayEntry);
}

/// 带动画的Popover组件
class _AnimatedPopover extends StatefulWidget {
  final VoidCallback closePopover;
  final double popoverWidth;
  final double popoverRight;
  final double popoverTop;
  final double statusBarHeight;
  final double screenWidth;

  const _AnimatedPopover({
    required this.closePopover,
    required this.popoverWidth,
    required this.popoverRight,
    required this.popoverTop,
    required this.statusBarHeight,
    required this.screenWidth,
  });

  @override
  State<_AnimatedPopover> createState() => _AnimatedPopoverState();
}

class _AnimatedPopoverState extends State<_AnimatedPopover>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // 启动动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      right: widget.popoverRight,
      top: widget.popoverTop + widget.statusBarHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.topRight,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: widget.popoverWidth,
            decoration: BoxDecoration(
              color: isDark
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
            child: PopoverMenu(onClose: widget.closePopover),
          ),
        ),
      ),
    );
  }
}
