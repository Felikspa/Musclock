import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/appflowy_theme.dart';
import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';
import '../providers/settings_storage.dart';
import '../widgets/musclock_app_bar.dart';
import '../widgets/plan/plan_selector.dart';
import '../widgets/plan/plan_detail_view.dart';
import '../widgets/plan/plan_setup_dialog.dart';
import '../widgets/plan/training_day_picker_dialog.dart';
import '../../data/database/database.dart';
import '../../core/constants/muscle_groups.dart';

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
  void initState() {
    super.initState();
    // Initialize preset plans in database on first load
    _initializePresetPlans();
  }

  Future<void> _initializePresetPlans() async {
    try {
      await ref.read(planRepositoryProvider).initializePresetPlans();
    } catch (e) {
      // Ignore errors - preset plans may already exist
      print('DEBUG: initializePresetPlans error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final selectedPlan = ref.watch(selectedPlanProvider);

    // Get colors from theme
    Color backgroundColor;
    Color cardColor;
    Color accentColor = MusclockBrandColors.primary;

    try {
      backgroundColor = isDark ? const Color(0xFF23262B) : Colors.white;
      cardColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);
    } catch (e) {
      backgroundColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
      cardColor = isDark ? const Color(0xFF252525) : const Color(0xFFFAFAFA);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: MusclockAppBar(
        title: l10n.plan,
        actions: [
          // Execution button (play/stop)
          _buildExecutionButton(context, ref, l10n, isDark, selectedPlan),
          // Edit button - all plans can be edited now
          IconButton(
            icon: Icon(
              Icons.edit,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () => _showEditPlanDialog(context, ref, l10n, isDark, selectedPlan),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(plansProvider);
          },
          color: accentColor,
          backgroundColor: cardColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
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
                  child: PlanDetailView(
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
    // Check if this is a preset plan
    final isPreset = _isPresetPlan(planName);
    
    // For preset plans, check if they exist in database; if not, use template data
    TrainingPlan? plan;
    if (isPreset) {
      final plansAsync = ref.read(plansProvider);
      final plans = plansAsync.valueOrNull ?? [];
      
      try {
        plan = plans.firstWhere((p) => p.name == planName);
      } catch (_) {
        // Preset plan not in database - use template data
        final schedule = WorkoutTemplates.getSchedule(planName);
        if (schedule != null) {
          // Create a virtual plan ID for preset plans not in database
          final virtualPlanId = 'preset_${planName.hashCode}';
          // Show dialog with template data - it will load items from DB first,
          // then we need to handle the case where they're not found
          if (!context.mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => PlanSetupDialog(
              planId: virtualPlanId,
              planName: planName,
              cycleLengthDays: schedule.length,
              l10n: l10n,
              isDark: isDark,
            ),
          );
          return;
        }
      }
    } else {
      // Custom plan - get from database
      final plansAsync = ref.read(plansProvider);
      final plans = plansAsync.valueOrNull ?? [];
      plan = plans.firstWhere(
        (p) => p.name == planName,
        orElse: () => throw Exception('Plan not found'),
      );
    }

    if (!context.mounted) return;

    // At this point, plan should be non-null
    final planData = plan!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PlanSetupDialog(
        planId: planData.id,
        planName: planData.name,
        cycleLengthDays: planData.cycleLengthDays,
        l10n: l10n,
        isDark: isDark,
      ),
    );
  }

  /// Build the execution button (play/stop) for the app bar
  Widget _buildExecutionButton(BuildContext context, WidgetRef ref, AppLocalizations l10n, bool isDark, String selectedPlan) {
    final activePlanAsync = ref.watch(activePlanProvider);
    final activePresetPlan = ref.watch(activePresetPlanProvider);

    return activePlanAsync.when(
      data: (activePlan) {
        // Check if the selected plan is the one currently executing
        final isThisPlanExecuting = 
            (activePlan != null && activePlan.name == selectedPlan) ||
            (activePresetPlan == selectedPlan);

        // Only show red stop button when this specific plan is executing
        final isStopButton = isThisPlanExecuting;

        return IconButton(
          icon: Icon(
            isStopButton ? Icons.stop : Icons.play_arrow,
            color: isStopButton
                ? Colors.red  // Red when this plan is executing
                : AppTheme.accent,  // Green otherwise
          ),
          tooltip: isStopButton ? l10n.stopExecution : l10n.startExecution,
          onPressed: () => _handleExecutionTap(context, ref, l10n, isDark, selectedPlan, activePlan),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Handle execution button tap
  Future<void> _handleExecutionTap(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool isDark,
    String selectedPlan,
    TrainingPlan? activePlan,
  ) async {
    final isPreset = _isPresetPlan(selectedPlan);
    final activePreset = ref.read(activePresetPlanProvider);

    // Determine if this specific plan is executing
    final isThisPlanExecuting = isPreset
        ? activePreset == selectedPlan
        : activePlan?.name == selectedPlan;

    // Check if ANY plan is executing
    final isAnyExecuting = activePlan != null || activePreset != null;

    if (isThisPlanExecuting) {
      // Stop this plan's execution
      if (isPreset) {
        await SettingsStorage.setActivePresetPlan(null, null);
        ref.read(activePresetPlanProvider.notifier).state = null;
        ref.read(activePresetDayIndexProvider.notifier).state = 1;
      } else {
        await ref.read(planRepositoryProvider).clearActivePlan();
        ref.invalidate(activePlanProvider);
        ref.invalidate(plansProvider);
      }
    } else if (isAnyExecuting) {
      // Another plan is executing - stop it first, then start the new one
      // Stop current executing plan
      if (activePreset != null) {
        await SettingsStorage.setActivePresetPlan(null, null);
        ref.read(activePresetPlanProvider.notifier).state = null;
        ref.read(activePresetDayIndexProvider.notifier).state = 1;
      }
      if (activePlan != null) {
        await ref.read(planRepositoryProvider).clearActivePlan();
        ref.invalidate(activePlanProvider);
        ref.invalidate(plansProvider);
      }

      // Now start the new plan
      if (isPreset) {
        final cycleLengthDays = _getCycleLengthDays(selectedPlan) ?? 7;
        if (!context.mounted) return;
        final selectedDay = await showDialog<int>(
          context: context,
          builder: (context) => TrainingDayPickerDialog(
            cycleLengthDays: cycleLengthDays,
            planName: selectedPlan,
          ),
        );

        if (selectedDay != null) {
          await SettingsStorage.setActivePresetPlan(selectedPlan, selectedDay);
          await SettingsStorage.updatePresetPlanExecutedTime(selectedPlan);
          ref.read(activePresetPlanProvider.notifier).state = selectedPlan;
          ref.read(activePresetDayIndexProvider.notifier).state = selectedDay;
        }
      } else {
        final cycleLengthDays = _getCycleLengthDays(selectedPlan);
        if (cycleLengthDays != null && !context.mounted) return;
        if (!context.mounted) return;
        final selectedDay = await showDialog<int>(
          context: context,
          builder: (context) => TrainingDayPickerDialog(
            cycleLengthDays: cycleLengthDays ?? 7,
            planName: selectedPlan,
          ),
        );

        if (selectedDay != null) {
          await _startCustomPlanExecution(ref, selectedPlan, selectedDay);
        }
      }
    } else {
      // No plan is executing - start the new plan
      if (isPreset) {
        final cycleLengthDays = _getCycleLengthDays(selectedPlan) ?? 7;
        if (!context.mounted) return;
        final selectedDay = await showDialog<int>(
          context: context,
          builder: (context) => TrainingDayPickerDialog(
            cycleLengthDays: cycleLengthDays,
            planName: selectedPlan,
          ),
        );

        if (selectedDay != null) {
          await SettingsStorage.setActivePresetPlan(selectedPlan, selectedDay);
          await SettingsStorage.updatePresetPlanExecutedTime(selectedPlan);
          ref.read(activePresetPlanProvider.notifier).state = selectedPlan;
          ref.read(activePresetDayIndexProvider.notifier).state = selectedDay;
        }
      } else {
        final cycleLengthDays = _getCycleLengthDays(selectedPlan);
        if (cycleLengthDays != null && !context.mounted) return;
        if (!context.mounted) return;
        final selectedDay = await showDialog<int>(
          context: context,
          builder: (context) => TrainingDayPickerDialog(
            cycleLengthDays: cycleLengthDays ?? 7,
            planName: selectedPlan,
          ),
        );

        if (selectedDay != null) {
          await _startCustomPlanExecution(ref, selectedPlan, selectedDay);
        }
      }
    }
  }

  /// Start execution of a custom plan
  Future<void> _startCustomPlanExecution(WidgetRef ref, String planName, int dayIndex) async {
    final plansAsync = ref.read(plansProvider);
    final plans = plansAsync.valueOrNull ?? [];

    final plan = plans.firstWhere(
      (p) => p.name == planName,
      orElse: () => throw Exception('Plan not found'),
    );

    // Update last executed time for sorting
    await ref.read(planRepositoryProvider).updatePlanLastExecuted(plan.id);
    await ref.read(planRepositoryProvider).setActivePlan(plan.id, dayIndex);
    ref.invalidate(activePlanProvider);
    ref.invalidate(plansProvider);
  }

  /// Get cycle length days for a plan
  int? _getCycleLengthDays(String planName) {
    // Check preset plans
    final schedule = WorkoutTemplates.getSchedule(planName);
    if (schedule != null) {
      return schedule.length;
    }

    // For custom plans, look up from database
    final plansAsync = ref.read(plansProvider);
    final plans = plansAsync.valueOrNull ?? [];
    try {
      final plan = plans.firstWhere((p) => p.name == planName);
      return plan.cycleLengthDays;
    } catch (_) {
      return null;
    }
  }
}
