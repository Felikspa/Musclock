import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/settings/popover_menu.dart';

/// AppFlowy风格的顶部导航栏组件
/// 左侧显示页面标题，右侧显示更多按钮（用于打开设置菜单）
class MusclockAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const MusclockAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
    this.leading,
  });

  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 获取背景色
    Color backgroundColor;
    Color borderColor;

    backgroundColor = isDark
        ? const Color(0xFF23262B).withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);
    borderColor = isDark
        ? const Color(0xFF23262B).withValues(alpha: 0.5)
        : const Color(0x141F2329);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 3,
          sigmaY: 3,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: borderColor),
            ),
            color: backgroundColor,
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  // 返回按钮或空白
                  if (showBackButton)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 20,
                      ),
                      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                    )
                  else if (leading != null)
                    leading!
                  else
                    const SizedBox(width: 16),

                  // 页面标题
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // 自定义操作按钮
                  if (actions != null) ...actions!,

                  // 更多按钮（设置菜单）
                  _buildMoreButton(context, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context, bool isDark) {
    return Builder(
      builder: (context) {
        return IconButton(
          icon: Icon(
            Icons.more_horiz,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          onPressed: () {
            // 获取按钮的位置来显示Popover
            final RenderBox button = context.findRenderObject() as RenderBox;
            final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
            final position = button.localToGlobal(Offset.zero, ancestor: overlay);
            showPopoverMenu(context, position);
          },
        );
      },
    );
  }
}

/// 带滚动效果的AppBar
/// 当滚动时会逐渐隐藏
class MusclockSliverAppBar extends ConsumerWidget {
  const MusclockSliverAppBar({
    super.key,
    required this.title,
    required this.child,
    this.pinned = true,
    this.actions,
  });

  final String title;
  final Widget child;
  final bool pinned;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color borderColor;

    backgroundColor = isDark
        ? const Color(0xFF23262B).withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);
    borderColor = isDark
        ? const Color(0xFF23262B).withValues(alpha: 0.5)
        : const Color(0x141F2329);

    return SliverAppBar(
      pinned: pinned,
      expandedHeight: kToolbarHeight,
      backgroundColor: backgroundColor,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: borderColor),
            ),
          ),
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              onPressed: () {
                // 获取按钮的位置来显示Popover
                final RenderBox button = context.findRenderObject() as RenderBox;
                final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
                final position = button.localToGlobal(Offset.zero, ancestor: overlay);
                showPopoverMenu(context, position);
              },
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 0,
          color: borderColor,
        ),
      ),
    );
  }
}
