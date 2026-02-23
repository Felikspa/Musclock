import 'package:flutter/material.dart';

/// Category spacer - uniform space and divider between categories
class SettingsCategorySpacer extends StatelessWidget {
  const SettingsCategorySpacer({
    super.key,
    this.topSpacing,
    this.bottomSpacing,
  });

  final double? topSpacing;
  final double? bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        top: topSpacing ?? 20,
        bottom: bottomSpacing ?? 20,
      ),
      child: Divider(
        color: isDark ? Colors.white12 : Colors.black12,
      ),
    );
  }
}
