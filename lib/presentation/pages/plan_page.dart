import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/plan/plan_selector.dart';
import '../widgets/plan/plan_details_widget.dart';
import '../widgets/plan/plan_setup_dialog.dart';

// Provider for all plan names (preset + custom)
final allPlanNamesProvider = Provider<List<String>>((ref) {
  final presetPlans = ['PPL', 'Upper/Lower', 'Bro Split'];
  final customPlansAsync = ref.watch(plansProvider);
  
  return customPlansAsync.when(
    data: (customPlans) => [...presetPlans, ...customPlans.map((p) => p.name)],
    loading: () => presetPlans,
    error: (e, s) => presetPlans,
  );
});

class PlanPage extends ConsumerStatefulWidget {
  const PlanPage({super.key});

  @override
  ConsumerState<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends ConsumerState<PlanPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedPlan = ref.watch(selectedPlanProvider);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(plansProvider);
          },
          color: AppTheme.accent,
          backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.plan,
                        style: TextStyle(
                          color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      // Edit button (only show for custom plans)
                      if (!_isPresetPlan(selectedPlan))
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                          ),
                          onPressed: () => _showEditPlanDialog(context, ref, l10n, isDark, selectedPlan),
                        ),
                    ],
                  ),
                ),

                // Plan Selector
                PlanSelector(
                  selectedPlan: selectedPlan,
                  onPlanSelected: (plan) {
                    ref.read(selectedPlanProvider.notifier).state = plan;
                  },
                  isDark: isDark,
                  onCreatePlan: () => _showCreatePlanDialog(context, ref, l10n, isDark),
                ),

                const SizedBox(height: 16),

                // Plan Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PlanDetailsWidget(
                    planName: selectedPlan,
                    isDark: isDark,
                    l10n: l10n,
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isPresetPlan(String planName) {
    return ['PPL', 'Upper/Lower', 'Bro Split'].contains(planName);
  }

  void _showCreatePlanDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, bool isDark) {
    // DEBUG: Print to verify this is being called
    print('DEBUG: _showCreatePlanDialog called - opening PlanSetupDialog');
    
    // Directly open PlanSetupDialog with null parameters (new plan mode)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PlanSetupDialog(
        planId: null,
        planName: null,
        cycleLengthDays: null,
        l10n: l10n,
        isDark: isDark,
      ),
    );
  }

  Future<void> _showEditPlanDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, bool isDark, String planName) async {
    // Get the plan details
    final plansAsync = ref.read(plansProvider);
    final plans = plansAsync.valueOrNull ?? [];
    final plan = plans.firstWhere(
      (p) => p.name == planName,
      orElse: () => throw Exception('Plan not found'),
    );

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PlanSetupDialog(
        planId: plan.id,
        planName: plan.name,
        cycleLengthDays: plan.cycleLengthDays,
        l10n: l10n,
        isDark: isDark,
      ),
    );
  }
}
