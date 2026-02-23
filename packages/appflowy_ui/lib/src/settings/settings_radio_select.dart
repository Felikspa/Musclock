import 'package:flutter/material.dart';

/// Radio item data for settings radio select
class SettingsRadioItem<T> {
  const SettingsRadioItem({
    required this.value,
    required this.label,
    required this.isSelected,
    this.icon,
  });

  final T value;
  final String label;
  final bool isSelected;
  final Widget? icon;
}

/// Settings radio select - horizontal radio button group
class SettingsRadioSelect<T> extends StatelessWidget {
  const SettingsRadioSelect({
    super.key,
    required this.items,
    required this.onChanged,
    this.selectedItem,
  });

  final List<SettingsRadioItem<T>> items;
  final void Function(SettingsRadioItem<T>) onChanged;
  final SettingsRadioItem<T>? selectedItem;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: 24,
      runSpacing: 8,
      children: items.map((item) => _buildRadioItem(context, item, primaryColor, isDark)).toList(),
    );
  }

  Widget _buildRadioItem(BuildContext context, SettingsRadioItem<T> item, Color primaryColor, bool isDark) {
    return GestureDetector(
      onTap: () => onChanged(item),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: item.isSelected
                    ? primaryColor
                    : (isDark ? Colors.white54 : Colors.black38),
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: item.isSelected
                    ? primaryColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (item.icon != null) ...[item.icon!, const SizedBox(width: 4)],
          Text(
            item.label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
