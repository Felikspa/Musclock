import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

class TrainingDayPickerDialog extends ConsumerStatefulWidget {
  final int cycleLengthDays;
  final String planName;

  const TrainingDayPickerDialog({
    super.key,
    required this.cycleLengthDays,
    required this.planName,
  });

  @override
  ConsumerState<TrainingDayPickerDialog> createState() => _TrainingDayPickerDialogState();
}

class _TrainingDayPickerDialogState extends ConsumerState<TrainingDayPickerDialog> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = 1; // Default to Day 1
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l10n.setTrainingDay,
        style: TextStyle(
          color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.planName,
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Day label
                Text(
                  l10n.trainingDay,
                  style: TextStyle(
                    color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                // Wheel picker
                Container(
                  height: 150,
                  width: 80,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 40,
                    perspective: 0.005,
                    diameterRatio: 1.5,
                    physics: const FixedExtentScrollPhysics(),
                    controller: FixedExtentScrollController(initialItem: 0),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedDay = index + 1;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: widget.cycleLengthDays,
                      builder: (context, index) {
                        final day = index + 1;
                        return Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: day == _selectedDay
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: day == _selectedDay
                                  ? AppTheme.accent
                                  : isDark
                                      ? AppTheme.textSecondary
                                      : AppTheme.textSecondaryLight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ ${widget.cycleLengthDays}',
                  style: TextStyle(
                    color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: TextStyle(
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedDay),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.accent,
          ),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
