import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';

class SelectDateTimeSheet extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;

  const SelectDateTimeSheet({
    super.key,
    this.initialDate,
    this.minDate,
    this.maxDate,
  });

  @override
  State<SelectDateTimeSheet> createState() => _SelectDateTimeSheetState();
}

class _SelectDateTimeSheetState extends State<SelectDateTimeSheet> {
  late DateTime _selectedDate;
  late int _selectedHour;

  @override
  void initState() {
    super.initState();
    // Default to today if no initial date provided
    _selectedDate = widget.initialDate ?? DateTime.now();
    // Default to current hour
    _selectedHour = _selectedDate.hour;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    // Calculate date constraints
    final minDate = widget.minDate ?? now.subtract(const Duration(days: 90));
    final maxDate = widget.maxDate ?? now;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            l10n.selectTime,
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Date Selection
          Text(
            l10n.workoutTime,
            style: TextStyle(
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Date Picker Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Date picker
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: minDate,
                        lastDate: maxDate,
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            _selectedHour,
                          );
                        });
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                // Hour picker
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedHour,
                      items: List.generate(24, (index) {
                        return DropdownMenuItem(
                          value: index,
                          child: Text(
                            '${index.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedHour = value;
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                              value,
                            );
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context, _selectedDate);
              },
              child: Text(l10n.save),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
