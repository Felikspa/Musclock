import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database/database.dart';
import '../../providers/providers.dart';
import '../../widgets/muscle_group_helper.dart';

class PlanSetupDialog extends ConsumerStatefulWidget {
  final String planId;
  final String planName;
  final int cycleLengthDays;
  final AppLocalizations l10n;
  final bool isDark;

  const PlanSetupDialog({
    super.key,
    required this.planId,
    required this.planName,
    required this.cycleLengthDays,
    required this.l10n,
    required this.isDark,
  });

  @override
  ConsumerState<PlanSetupDialog> createState() => _PlanSetupDialogState();
}

class _PlanSetupDialogState extends ConsumerState<PlanSetupDialog> {
  late List<DayConfig> _dayConfigs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dayConfigs = List.generate(
      widget.cycleLengthDays,
      (index) => DayConfig(dayIndex: index, bodyPartIds: [], isRest: true),
    );
    _loadExistingItems();
  }

  Future<void> _loadExistingItems() async {
    final repo = ref.read(planRepositoryProvider);
    final existingItems = await repo.getPlanItemsByPlan(widget.planId);

    for (var item in existingItems) {
      if (item.dayIndex < _dayConfigs.length) {
        _dayConfigs[item.dayIndex] = DayConfig(
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
      _dayConfigs[dayIndex] = DayConfig(
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
                        return DayRow(
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

class DayConfig {
  final int dayIndex;
  final List<String> bodyPartIds;
  final bool isRest;

  DayConfig({
    required this.dayIndex,
    required this.bodyPartIds,
    required this.isRest,
  });
}

class DayRow extends StatelessWidget {
  final int dayIndex;
  final DayConfig config;
  final bool isDark;
  final AppLocalizations l10n;
  final AsyncValue<List<BodyPart>> bodyPartsAsync;
  final VoidCallback onTap;

  const DayRow({
    super.key,
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
