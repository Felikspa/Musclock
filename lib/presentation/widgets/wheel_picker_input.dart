import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_config.dart';

/// A wheel picker input widget with optional fine-tune buttons
/// 
/// [type] - The type of value: 'weight' or 'reps'
/// [minValue] - Minimum value
/// [maxValue] - Maximum value  
/// [step] - Step size for wheel scrolling
/// [defaultValue] - Default selected value
/// [fineStep] - Step size for fine-tune buttons (for weight only)
class WheelPickerInput extends StatefulWidget {
  final String type; // 'weight' or 'reps'
  final num minValue;
  final num maxValue;
  final num step;
  final num defaultValue;
  final num? fineStep; // For weight: 0.5kg step
  final ValueChanged<num> onChanged;
  final String label;

  const WheelPickerInput({
    super.key,
    required this.type,
    required this.minValue,
    required this.maxValue,
    required this.step,
    required this.defaultValue,
    this.fineStep,
    required this.onChanged,
    required this.label,
  });

  @override
  State<WheelPickerInput> createState() => _WheelPickerInputState();
}

class _WheelPickerInputState extends State<WheelPickerInput> {
  late FixedExtentScrollController _scrollController;
  late num _currentValue;
  bool _isHalfKgMode = false; // Track if we're in fine-tune (0.5kg) mode
  num _halfKgValue = 0; // Store the half kg offset value

  @override
  void initState() {
    super.initState();
    _currentValue = widget.defaultValue;
    // Check if initial value has half kg
    _updateHalfKgMode(_currentValue);
    // Calculate initial index
    final initialIndex = ((_currentValue - widget.minValue) / widget.step).round();
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  /// Update half kg mode based on current value
  void _updateHalfKgMode(num value) {
    final baseValue = (value / widget.step).round() * widget.step;
    final remainder = (value - baseValue).abs();
    // If remainder is close to half step (0.5 for weight), we're in half kg mode
    if (widget.fineStep != null && remainder >= widget.fineStep! / 2) {
      _isHalfKgMode = true;
      _halfKgValue = value;
    } else {
      _isHalfKgMode = false;
      _halfKgValue = 0;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Generate list of values based on min, max, and step
  List<num> get _values {
    final List<num> values = [];
    for (num v = widget.minValue; v <= widget.maxValue; v += widget.step) {
      values.add(v);
    }
    return values;
  }

  /// Handle fine-tune button press
  void _handleFineTune(bool increase) {
    final step = widget.fineStep ?? widget.step;
    num newValue;

    if (increase) {
      newValue = _currentValue + step;
      if (newValue > widget.maxValue) return;
    } else {
      newValue = _currentValue - step;
      if (newValue < widget.minValue) return;
    }

    setState(() {
      _currentValue = newValue;
      _isHalfKgMode = true; // Enter half kg mode when using fine-tune
      _halfKgValue = newValue;
    });

    // Sync scroll controller position with fine-tune
    final newIndex = ((newValue - widget.minValue) / widget.step).round();
    // Clamp index to valid range
    final clampedIndex = newIndex.clamp(0, _values.length - 1);
    _scrollController.animateToItem(
      clampedIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );

    widget.onChanged(newValue);
  }

  /// Format value for display
  String _formatValue(num value) {
    if (widget.type == 'weight') {
      // Weight: show with 1 decimal if it's a half kg
      if (value is double && value != value.roundToDouble()) {
        return value.toStringAsFixed(1);
      }
      return value.toInt().toString();
    } else {
      // Reps: show as integer
      return value.toInt().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeight = widget.type == 'weight';
    final values = _values;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? AppTheme.textSecondaryLight : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        
        // Wheel picker with fine-tune buttons
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: isDark 
              ? AppTheme.cardDark.withOpacity(0.5)
              : AppThemeConfig.cardLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark 
                ? AppThemeConfig.secondaryDark.withOpacity(0.3)
                : AppThemeConfig.secondaryLight.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              // Fine-tune buttons (for weight only)
              if (isWeight && widget.fineStep != null)
                _buildFineTuneButtons(),
              
              // Wheel picker
              Expanded(
                child: Stack(
                  children: [
                    // Selection highlight
                    Center(
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppThemeConfig.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppThemeConfig.accent.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                    // Wheel
                    ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        final newValue = values[index];
                        setState(() {
                          _currentValue = newValue;
                          // Exit half kg mode when user scrolls wheel
                          _isHalfKgMode = false;
                          _halfKgValue = 0;
                        });
                        widget.onChanged(newValue);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: values.length,
                        builder: (context, index) {
                          final value = values[index];
                          final isSelected = value == _currentValue;

                          return Center(
                            child: Text(
                              _formatValue(value),
                              style: TextStyle(
                                fontSize: isSelected ? 20 : 16,
                                fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                                color: isSelected
                                  ? AppThemeConfig.accent
                                  : (isDark
                                      ? AppThemeConfig.textPrimary
                                      : AppThemeConfig.textPrimaryLight),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Half kg mode overlay - shows the fine-tuned value
                    if (_isHalfKgMode)
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppThemeConfig.accent.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _formatValue(_halfKgValue),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Unit label
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  isWeight ? 'kg' : '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark 
                      ? AppThemeConfig.textSecondary 
                      : AppThemeConfig.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFineTuneButtons() {
    final canDecrease = _currentValue > widget.minValue;
    final canIncrease = _currentValue < widget.maxValue;

    return Container(
      width: 44,
      margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppThemeConfig.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Increase button
          IconButton(
            onPressed: canIncrease ? () => _handleFineTune(true) : null,
            icon: Icon(
              Icons.keyboard_arrow_up,
              size: 20,
              color: canIncrease
                ? AppThemeConfig.accent
                : AppThemeConfig.accent.withOpacity(0.3),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
            tooltip: '+${widget.fineStep}',
          ),
          // Small step indicator - simplified to +/- symbol
          Text(
            '+/-',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppThemeConfig.accent.withOpacity(0.7),
            ),
          ),
          // Decrease button
          IconButton(
            onPressed: canDecrease ? () => _handleFineTune(false) : null,
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: canDecrease
                ? AppThemeConfig.accent
                : AppThemeConfig.accent.withOpacity(0.3),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
            tooltip: '-${widget.fineStep}',
          ),
        ],
      ),
    );
  }
}
