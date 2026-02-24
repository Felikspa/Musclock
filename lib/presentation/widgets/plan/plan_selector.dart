import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../providers/settings_storage.dart';

/// Helper class to hold plan info with execution time for sorting
class _PlanWithTime {
  final String name;
  final bool isPreset;
  final DateTime? lastExecuted;
  _PlanWithTime({required this.name, required this.isPreset, this.lastExecuted});
}

class PlanSelector extends ConsumerStatefulWidget {
  final String selectedPlan;
  final Function(String) onPlanSelected;
  final bool isDark;
  final VoidCallback onCreatePlan;

  const PlanSelector({
    super.key,
    required this.selectedPlan,
    required this.onPlanSelected,
    required this.isDark,
    required this.onCreatePlan,
  });

  @override
  ConsumerState<PlanSelector> createState() => _PlanSelectorState();
}

class _PlanSelectorState extends ConsumerState<PlanSelector> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final presetPlans = ['PPL', 'Upper/Lower', 'Bro Split'];
    final plansAsync = ref.watch(plansProvider);
    final activePlanAsync = ref.watch(activePlanProvider);
    final activePresetPlan = ref.watch(activePresetPlanProvider);

    // Get the active plan name (custom plan)
    final activePlanName = activePlanAsync.when(
      data: (plan) => plan?.name,
      loading: () => null,
      error: (_, __) => null,
    );

    // Get all plans with their execution times for sorting
    final customPlans = plansAsync.when(
      data: (plans) => plans,
      loading: () => <dynamic>[],
      error: (_, __) => <dynamic>[],
    );

    // Get preset plan execution times from SettingsStorage
    final presetExecTimes = SettingsStorage.getLastExecutedPresetPlans();

    // Build list of all plans with execution times
    final List<_PlanWithTime> allPlansWithTime = [];

    // Add custom plans with their execution times
    for (final plan in customPlans) {
      allPlansWithTime.add(_PlanWithTime(
        name: plan.name,
        isPreset: false,
        lastExecuted: plan.lastExecutedAt,
      ));
    }

    // Add preset plans with their execution times (only if not already in database)
    final customPlanNames = customPlans.map((p) => p.name).toSet();
    for (final presetName in presetPlans) {
      // Only add preset if not already in database (to avoid duplicates after import)
      if (!customPlanNames.contains(presetName)) {
        allPlansWithTime.add(_PlanWithTime(
          name: presetName,
          isPreset: true,
          lastExecuted: presetExecTimes[presetName],
        ));
      }
    }

    // Sort by execution time (most recent first, null at the end)
    allPlansWithTime.sort((a, b) {
      if (a.lastExecuted == null && b.lastExecuted == null) return 0;
      if (a.lastExecuted == null) return 1;
      if (b.lastExecuted == null) return -1;
      return b.lastExecuted!.compareTo(a.lastExecuted!);
    });

    // Extract just the names, but keep executing plans at the top
    final List<String> allPlans = [];

    // First add the currently executing plans
    bool hasActiveCustom = activePlanName != null && customPlans.any((p) => p.name == activePlanName);
    if (hasActiveCustom) {
      allPlans.add(activePlanName);
    }
    if (activePresetPlan != null) {
      if (!allPlans.contains(activePresetPlan)) {
        allPlans.add(activePresetPlan);
      }
    }

    // Then add the rest sorted by execution time
    for (final planWithTime in allPlansWithTime) {
      if (!allPlans.contains(planWithTime.name)) {
        allPlans.add(planWithTime.name);
      }
    }

    // Show all plans when expanded, otherwise show first 4
    final hasMore = allPlans.length > 4;

    // Filter plans based on expanded state
    final displayPlans = _isExpanded ? allPlans : allPlans.take(4).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.selectTrainingPlan,
                style: TextStyle(
                  color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasMore)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...displayPlans.map((planName) {
                final isPreset = presetPlans.contains(planName);
                // Check both custom plan and preset plan execution status
                final isExecuting = planName == activePlanName ||
                    (isPreset && planName == activePresetPlan);
                return PlanChip(
                  plan: planName,
                  isSelected: planName == widget.selectedPlan,
                  isExecuting: isExecuting,
                  onTap: () => widget.onPlanSelected(planName),
                  isDark: widget.isDark,
                  icon: isPreset ? _getPlanIcon(planName) : Icons.fitness_center,
                );
              }),
              // Create Plan button at the end
              PlanChip(
                plan: '+',
                isSelected: false,
                isExecuting: false,
                onTap: widget.onCreatePlan,
                isDark: widget.isDark,
                icon: Icons.add,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPlanIcon(String plan) {
    switch (plan) {
      case 'PPL':
        return Icons.rotate_right;
      case 'Upper/Lower':
        return Icons.swap_vert;
      case 'Bro Split':
        return Icons.calendar_view_week;
      default:
        return Icons.fitness_center;
    }
  }
}

class PlanChip extends StatelessWidget {
  final String plan;
  final bool isSelected;
  final bool isExecuting;
  final VoidCallback onTap;
  final bool isDark;
  final IconData icon;

  const PlanChip({
    super.key,
    required this.plan,
    required this.isSelected,
    this.isExecuting = false,
    required this.onTap,
    required this.isDark,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Use gold color for executing, green for selected only
    final executingColor = AppTheme.executing;
    final selectedColor = AppTheme.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // Executing plan: gold background, Selected plan: green background
          color: isExecuting
              ? executingColor.withOpacity(0.15)
              : isSelected
                  ? selectedColor.withOpacity(0.2)
                  : isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isExecuting
                ? executingColor
                : isSelected
                    ? selectedColor
                    : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isExecuting
                  ? executingColor
                  : isSelected
                      ? selectedColor
                      : isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
              size: 16,
            ),
            if (plan != '+') ...[
              const SizedBox(width: 6),
              Text(
                plan,
                style: TextStyle(
                  color: isExecuting
                      ? executingColor
                      : isSelected
                          ? selectedColor
                          : isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                  fontSize: 13,
                  fontWeight: isExecuting || isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
