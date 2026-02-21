import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/database.dart';
import '../providers/providers.dart';
import '../widgets/muscle_group_helper.dart';
import '../widgets/plan/plan_selector.dart';
import '../widgets/plan/plan_details_widget.dart';

// State provider for selected plan
final selectedPlanProvider = StateProvider<String>((ref) => 'PPL');

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
      builder: (context) => _PlanSetupDialog(
        planId: planId,
        planName: planName,
        cycleLengthDays: cycleLengthDays,
        l10n: l10n,
        isDark: isDark,
      ),
    );
  }
}

class _PlanSetupDialog extends ConsumerStatefulWidget {
  final String planId;
  final String planName;
  final int cycleLengthDays;
  final AppLocalizations l10n;
  final bool isDark;

  const _PlanSetupDialog({
    required this.planId,
    required this.planName,
    required this.cycleLengthDays,
    required this.l10n,
    required this.isDark,
  });

  @override
  ConsumerState<_PlanSetupDialog> createState() => _PlanSetupDialogState();
}

class _PlanSetupDialogState extends ConsumerState<_PlanSetupDialog> {
  late List<_DayConfig> _dayConfigs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dayConfigs = List.generate(
      widget.cycleLengthDays,
      (index) => _DayConfig(dayIndex: index, bodyPartIds: [], isRest: true),
    );
    _loadExistingItems();
  }

  Future<void> _loadExistingItems() async {
    final repo = ref.read(planRepositoryProvider);
    final existingItems = await repo.getPlanItemsByPlan(widget.planId);

    for (var item in existingItems) {
      if (item.dayIndex < _dayConfigs.length) {
        _dayConfigs[item.dayIndex] = _DayConfig(
          dayIndex: item.dayIndex,
          bodyPartIds: item.bodyPartIds.split(',').where((s) => s.isNotEmpty).toList(),
          isRest: item.bodyPartIds.isEmpty,
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveDayConfig(int dayIndex, List<String> bodyPartIds, bool isRest) async {
    final repo = ref.read(planRepositoryProvider);

    // Remove existing item for this day if any
    final existingItems = await repo.getPlanItemsByPlan(widget.planId);
    final existingItem = existingItems.where((item) => item.dayIndex == dayIndex).firstOrNull;

    if (existingItem != null) {
      await repo.deletePlanItem(existingItem.id);
    }

    // Add new item
    if (!isRest && bodyPartIds.isNotEmpty) {
      await repo.insertPlanItem(PlanItemsCompanion.insert(
        id: DateTime.now().millisecondsSinceEpoch.toString() + dayIndex.toString(),
        planId: widget.planId,
        dayIndex: dayIndex,
        bodyPartIds: bodyPartIds.join(','),
      ));
    }

    setState(() {
      _dayConfigs[dayIndex] = _DayConfig(
        dayIndex: dayIndex,
        bodyPartIds: bodyPartIds,
        isRest: isRest,
      );
    });
  }

  void _showDayEditDialog(int dayIndex) {
    final currentConfig = _dayConfigs[dayIndex];
    List<String> selectedBodyPartIds = List.from(currentConfig.bodyPartIds);
    bool isRest = currentConfig.isRest;

    final bodyPartsAsync = ref.read(bodyPartsProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: widget.isDark ? AppTheme.cardDark : AppTheme.cardLight,
          title: Text(
            'Day ${dayIndex + 1}',
            style: TextStyle(
              color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rest toggle
                Row(
                  children: [
                    Text(
                      widget.l10n.rest,
                      style: TextStyle(
                        color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: isRest,
                      onChanged: (value) {
                        setDialogState(() {
                          isRest = value;
                          if (value) {
                            selectedBodyPartIds.clear();
                          }
                        });
                      },
                      activeColor: AppTheme.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!isRest) ...[
                  Text(
                    'Select Body Parts:',
                    style: TextStyle(
                      color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  bodyPartsAsync.when(
                    data: (bodyParts) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: bodyParts.map((bp) {
                        final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bp.name);
                        final color = AppTheme.getMuscleColor(muscleGroup);
                        final isSelected = selectedBodyPartIds.contains(bp.id);

                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              if (isSelected) {
                                selectedBodyPartIds.remove(bp.id);
                              } else {
                                selectedBodyPartIds.add(bp.id);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withOpacity(0.3) : (widget.isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? color : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              bp.name,
                              style: TextStyle(
                                color: isSelected ? color : (widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight),
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, s) => Text('Error: $e'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(widget.l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveDayConfig(dayIndex, selectedBodyPartIds, isRest);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(widget.l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: widget.isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        height: screenHeight * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.planName,
                  style: TextStyle(
                    color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.invalidate(plansProvider);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap a day to set training',
              style: TextStyle(
                color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            // Days list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _dayConfigs.length,
                      itemBuilder: (context, index) {
                        final config = _dayConfigs[index];
                        return _DayRow(
                          dayIndex: index,
                          config: config,
                          isDark: widget.isDark,
                          l10n: widget.l10n,
                          bodyPartsAsync: ref.watch(bodyPartsProvider),
                          onTap: () => _showDayEditDialog(index),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.invalidate(plansProvider);
                  ref.read(selectedPlanProvider.notifier).state = widget.planName;
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayConfig {
  final int dayIndex;
  final List<String> bodyPartIds;
  final bool isRest;

  _DayConfig({
    required this.dayIndex,
    required this.bodyPartIds,
    required this.isRest,
  });
}

class _DayRow extends StatelessWidget {
  final int dayIndex;
  final _DayConfig config;
  final bool isDark;
  final AppLocalizations l10n;
  final AsyncValue<List<BodyPart>> bodyPartsAsync;
  final VoidCallback onTap;

  const _DayRow({
    required this.dayIndex,
    required this.config,
    required this.isDark,
    required this.l10n,
    required this.bodyPartsAsync,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Day label
            SizedBox(
              width: 60,
              child: Text(
                'Day ${dayIndex + 1}',
                style: TextStyle(
                  color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Body parts or rest
            Expanded(
              child: config.isRest
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        l10n.rest,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : bodyPartsAsync.when(
                      data: (bodyParts) {
                        final names = bodyParts
                            .where((bp) => config.bodyPartIds.contains(bp.id))
                            .map((bp) => bp.name)
                            .toList();

                        if (names.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              l10n.rest,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }

                        return Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: names.map((name) {
                            final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(name);
                            final color = AppTheme.getMuscleColor(muscleGroup);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
            ),
            // Arrow indicator
            Icon(
              Icons.chevron_right,
              color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
