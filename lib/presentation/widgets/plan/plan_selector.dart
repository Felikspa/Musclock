import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

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
    final presetPlans = ['PPL', 'Upper/Lower', 'Bro Split'];
    final plansAsync = ref.watch(plansProvider);

    final allPlans = [
      ...presetPlans,
      ...plansAsync.when(
        data: (plans) => plans.map((p) => p.name),
        loading: () => <String>[],
        error: (_, __) => <String>[],
      ),
    ];

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
                'Select Training Plan',
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
                return PlanChip(
                  plan: planName,
                  isSelected: planName == widget.selectedPlan,
                  onTap: () => widget.onPlanSelected(planName),
                  isDark: widget.isDark,
                  icon: isPreset ? _getPlanIcon(planName) : Icons.fitness_center,
                );
              }),
              // Create Plan button at the end
              PlanChip(
                plan: '+',
                isSelected: false,
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
  final VoidCallback onTap;
  final bool isDark;
  final IconData icon;

  const PlanChip({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.accent.withOpacity(0.2) 
              : isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected 
                ? AppTheme.accent 
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? AppTheme.accent 
                  : isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
              size: 16,
            ),
            if (plan != '+') ...[
              const SizedBox(width: 6),
              Text(
                plan,
                style: TextStyle(
                  color: isSelected 
                      ? AppTheme.accent 
                      : isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                  fontSize: 13,
                  fontWeight: isSelected 
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
