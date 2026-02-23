import 'package:flutter/material.dart';

/// Settings category - renders a section with title and children
class SettingsCategory extends StatelessWidget {
  const SettingsCategory({
    super.key,
    required this.title,
    this.description,
    this.children = const [],
  });

  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        if (description?.isNotEmpty ?? false) ...[
          Text(
            description!,
            maxLines: 4,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...children,
      ],
    );
  }
}
