import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/database.dart';
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
    error: (_, __) => presetPlans,
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
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
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
                ),

                const SizedBox(height: 24),

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePlanDialog(context, ref, l10n, isDark),
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.primaryDark,
        icon: const Icon(Icons.add),
        label: Text(l10n.createPlan),
      ),
    );
  }

  void _showCreatePlanDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, bool isDark) {
    final nameController = TextEditingController();
    final cycleLengthController = TextEditingController(text: '7');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        title: Text(
          l10n.createPlan,
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(
                color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: l10n.planName,
                labelStyle: TextStyle(
                  color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cycleLengthController,
              style: TextStyle(
                color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: l10n.cycleLength,
                suffixText: l10n.days,
                labelStyle: TextStyle(
                  color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final cycleLength = int.tryParse(cycleLengthController.text) ?? 7;
                final repo = ref.read(planRepositoryProvider);
                final planId = DateTime.now().millisecondsSinceEpoch.toString();

                await repo.insertPlan(TrainingPlansCompanion.insert(
                  id: planId,
                  name: nameController.text,
                  cycleLengthDays: cycleLength,
                  createdAt: DateTime.now().toUtc(),
                ));

                ref.invalidate(plansProvider);

                if (context.mounted) {
                  // Close the create dialog first
                  Navigator.pop(context);

                  // Then show the plan setup dialog
                  _showPlanSetupDialog(context, ref, l10n, isDark, planId, nameController.text, cycleLength);
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showPlanSetupDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, bool isDark, String planId, String planName, int cycleLengthDays) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PlanSetupDialog(
        planId: planId,
        planName: planName,
        cycleLengthDays: cycleLengthDays,
        l10n: l10n,
        isDark: isDark,
      ),
    );
  }
}
