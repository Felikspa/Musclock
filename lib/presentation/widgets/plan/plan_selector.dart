import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class PlanSelector extends ConsumerWidget {
  final String selectedPlan;
  final Function(String) onPlanSelected;
  final bool isDark;

  const PlanSelector({
    super.key,
    required this.selectedPlan,
    required this.onPlanSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetPlans = ['PPL', 'Upper/Lower', 'Bro Split'];
    final plansAsync = ref.watch(plansProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Training Plan',
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Preset plans
              ...presetPlans.map((plan) => PlanChip(
                plan: plan,
                isSelected: plan == selectedPlan,
                onTap: () => onPlanSelected(plan),
                isDark: isDark,
                icon: _getPlanIcon(plan),
              )),
              // Custom plans
              ...plansAsync.when(
                data: (plans) => plans.map((plan) => PlanChip(
                  plan: plan.name,
                  isSelected: plan.name == selectedPlan,
                  onTap: () => onPlanSelected(plan.name),
                  isDark: isDark,
                  icon: Icons.fitness_center,
                  isCustom: true,
                )),
                loading: () => [],
                error: (_, __) => [],
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
  final bool isCustom;

  const PlanChip({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.icon,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.accent.withOpacity(0.2) 
              : isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
          borderRadius: BorderRadius.circular(12),
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
              size: 18,
            ),
            const SizedBox(width: 8),
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
            if (isCustom) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.edit,
                size: 12,
                color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
