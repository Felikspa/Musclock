import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database/database.dart';
import '../../providers/providers.dart';
import '../../widgets/muscle_group_helper.dart';

class PlanSetupDialog extends ConsumerStatefulWidget {
  final String? planId; // null for new plan
  final String? planName; // null for new plan
  final int? cycleLengthDays; // null for new plan
  final AppLocalizations l10n;
  final bool isDark;

  const PlanSetupDialog({
    super.key,
    this.planId,
    this.planName,
    this.cycleLengthDays,
    required this.l10n,
    required this.isDark,
  });

  @override
  ConsumerState<PlanSetupDialog> createState() => _PlanSetupDialogState();
}

class _PlanSetupDialogState extends ConsumerState<PlanSetupDialog> {
  late TextEditingController _nameController;
  late int _cycleLength;
  late List<DayConfig> _dayConfigs;
  bool _isLoading = true;
  bool _isNewPlan = false;
  String? _currentPlanId;

  @override
  void initState() {
    super.initState();
    _isNewPlan = widget.planId == null;
    _currentPlanId = widget.planId ?? DateTime.now().millisecondsSinceEpoch.toString();

    // DEBUG
    print('DEBUG: PlanSetupDialog init - planId: ${widget.planId}, _isNewPlan: $_isNewPlan');

    _nameController = TextEditingController(text: widget.planName ?? '');
    _cycleLength = widget.cycleLengthDays ?? 7;

    _initDayConfigs();
  }

  void _initDayConfigs() {
    _dayConfigs = List.generate(
      _cycleLength,
      (index) => DayConfig(dayIndex: index, bodyPartIds: [], isRest: true),
    );
    _loadExistingItems();
  }

  void _updateCycleLength(int newLength) {
    if (newLength < 1 || newLength > 365) return;

    setState(() {
      _cycleLength = newLength;
      // Reinitialize day configs with the new cycle length
      _dayConfigs = List.generate(
        _cycleLength,
        (index) => DayConfig(dayIndex: index, bodyPartIds: [], isRest: true),
      );
    });
  }

  Future<void> _loadExistingItems() async {
    if (widget.planId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    final repo = ref.read(planRepositoryProvider);
    final existingItems = await repo.getPlanItemsByPlan(widget.planId!);

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

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.l10n.deletePlan),
        content: Text(widget.l10n.deletePlanConfirmation(widget.planName ?? '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(widget.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(widget.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && _currentPlanId != null) {
      final repo = ref.read(planRepositoryProvider);
      // Delete all plan items first
      final items = await repo.getPlanItemsByPlan(_currentPlanId!);
      for (var item in items) {
        await repo.deletePlanItem(item.id);
      }
      // Then delete the plan
      await repo.deletePlan(_currentPlanId!);
      
      // Refresh providers
      ref.invalidate(plansProvider);
      
      // If this was the selected plan, clear selection
      if (ref.read(selectedPlanProvider) == widget.planName) {
        ref.read(selectedPlanProvider.notifier).state = 'PPL';
      }
      
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _savePlan() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.planName)),
      );
      return;
    }

    final repo = ref.read(planRepositoryProvider);

    // Check if plan name already exists (only for new plans)
    if (_isNewPlan) {
      final exists = await repo.isPlanNameExists(_nameController.text);
      if (exists) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l10n.planNameExists),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Insert or update the plan
    if (_isNewPlan) {
      await repo.insertPlan(TrainingPlansCompanion.insert(
        id: _currentPlanId!,
        name: _nameController.text,
        cycleLengthDays: _cycleLength,
        createdAt: DateTime.now().toUtc(),
      ));
    } else {
      await repo.updatePlan(TrainingPlansCompanion(
        id: Value(_currentPlanId!),
        name: Value(_nameController.text),
        cycleLengthDays: Value(_cycleLength),
      ));
    }

    // Save all day configs
    for (var config in _dayConfigs) {
      await _saveDayConfig(config.dayIndex, config.bodyPartIds, config.isRest);
    }

    // Refresh providers and close
    ref.invalidate(plansProvider);
    ref.invalidate(planItemsProvider(_currentPlanId!));
    ref.read(selectedPlanProvider.notifier).state = _nameController.text;
    Navigator.pop(context);
  }

  Future<void> _toggleBodyPart(int dayIndex, String bodyPartId) async {
    final currentConfig = _dayConfigs[dayIndex];
    final List<String> newBodyPartIds;
    final bool newIsRest;

    if (currentConfig.isRest) {
      newBodyPartIds = [bodyPartId];
      newIsRest = false;
    } else if (currentConfig.bodyPartIds.contains(bodyPartId)) {
      newBodyPartIds = List.from(currentConfig.bodyPartIds)..remove(bodyPartId);
      newIsRest = newBodyPartIds.isEmpty;
    } else {
      newBodyPartIds = List.from(currentConfig.bodyPartIds)..add(bodyPartId);
      newIsRest = false;
    }

    await _saveDayConfig(dayIndex, newBodyPartIds, newIsRest);

    setState(() {
      _dayConfigs[dayIndex] = DayConfig(
        dayIndex: dayIndex,
        bodyPartIds: newBodyPartIds,
        isRest: newIsRest,
      );
    });
  }

  Future<void> _setRestDay(int dayIndex) async {
    await _saveDayConfig(dayIndex, [], true);
    setState(() {
      _dayConfigs[dayIndex] = DayConfig(
        dayIndex: dayIndex,
        bodyPartIds: [],
        isRest: true,
      );
    });
  }

  Future<void> _saveDayConfig(int dayIndex, List<String> bodyPartIds, bool isRest) async {
    if (_currentPlanId == null) return;
    
    final repo = ref.read(planRepositoryProvider);
    final existingItems = await repo.getPlanItemsByPlan(_currentPlanId!);
    final existingItem = existingItems.where((item) => item.dayIndex == dayIndex).firstOrNull;

    if (existingItem != null) {
      await repo.deletePlanItem(existingItem.id);
    }

    if (!isRest && bodyPartIds.isNotEmpty) {
      await repo.insertPlanItem(PlanItemsCompanion.insert(
        id: DateTime.now().millisecondsSinceEpoch.toString() + dayIndex.toString(),
        planId: _currentPlanId!,
        dayIndex: dayIndex,
        bodyPartIds: bodyPartIds.join(','),
      ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // DEBUG
    print('DEBUG: PlanSetupDialog build - _isNewPlan: $_isNewPlan');

    final screenHeight = MediaQuery.of(context).size.height;
    final bodyPartsAsync = ref.watch(bodyPartsProvider);

    return Dialog(
      backgroundColor: widget.isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        height: screenHeight * 0.88,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button and delete option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _isNewPlan 
                        ? (_nameController.text.isEmpty ? widget.l10n.createPlan : _nameController.text)
                        : widget.l10n.editPlan,
                    style: TextStyle(
                      color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isNewPlan)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                        ),
                        onPressed: () => _showDeleteConfirmation(context),
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
              ],
            ),
            const SizedBox(height: 16),

            // Plan name input
            TextField(
              controller: _nameController,
              style: TextStyle(
                color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
              ),
              decoration: InputDecoration(
                labelText: widget.l10n.planName,
                labelStyle: TextStyle(
                  color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                ),
                hintText: widget.l10n.enterName,
                hintStyle: TextStyle(
                  color: widget.isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Update header when name changes
              },
            ),
            const SizedBox(height: 12),

            // Cycle length with +/- buttons
            Row(
              children: [
                Text(
                  widget.l10n.cycleLength,
                  style: TextStyle(
                    color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                // Minus button
                GestureDetector(
                  onTap: () => _updateCycleLength(_cycleLength - 1),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.remove,
                      color: AppTheme.accent,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Cycle length display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$_cycleLength ${widget.l10n.days}',
                    style: TextStyle(
                      color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Plus button
                GestureDetector(
                  onTap: () => _updateCycleLength(_cycleLength + 1),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppTheme.accent,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Days list with inline body part selection
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : bodyPartsAsync.when(
                      data: (bodyParts) => StatefulBuilder(
                        builder: (context, setDialogState) {
                          return ListView.builder(
                            itemCount: _dayConfigs.length,
                            itemBuilder: (context, index) {
                              final config = _dayConfigs[index];
                              return _DayRowInline(
                                dayIndex: index,
                                config: config,
                                bodyParts: bodyParts,
                                isDark: widget.isDark,
                                l10n: widget.l10n,
                                onToggleBodyPart: (bodyPartId) {
                                  _toggleBodyPart(index, bodyPartId);
                                  setDialogState(() {});
                                },
                                onSetRest: () {
                                  _setRestDay(index);
                                  setDialogState(() {});
                                },
                              );
                            },
                          );
                        },
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('Error: $e')),
                    ),
            ),
            const SizedBox(height: 16),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                ),
                child: Text(_isNewPlan ? widget.l10n.createPlan : widget.l10n.done),
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

class _DayRowInline extends StatelessWidget {
  final int dayIndex;
  final DayConfig config;
  final List<BodyPart> bodyParts;
  final bool isDark;
  final AppLocalizations l10n;
  final Function(String) onToggleBodyPart;
  final VoidCallback onSetRest;

  const _DayRowInline({
    required this.dayIndex,
    required this.config,
    required this.bodyParts,
    required this.isDark,
    required this.l10n,
    required this.onToggleBodyPart,
    required this.onSetRest,
  });

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode.startsWith('zh');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Day ${dayIndex + 1}',
              style: TextStyle(
                color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _BodyPartChip(
                label: l10n.rest,
                color: Colors.grey,
                isSelected: config.isRest,
                onTap: onSetRest,
              ),
              ...bodyParts.map((bp) {
                final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bp.name);
                final color = muscleGroup != null 
                    ? AppTheme.getMuscleColor(muscleGroup) 
                    : MuscleGroupHelper.getColorForBodyPart(bp.name);
                final isSelected = config.bodyPartIds.contains(bp.id);
                final displayName = muscleGroup != null
                    ? muscleGroup.getLocalizedName(isChinese ? 'zh' : 'en')
                    : bp.name;

                return _BodyPartChip(
                  label: displayName,
                  color: color,
                  isSelected: isSelected,
                  onTap: () => onToggleBodyPart(bp.id),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _BodyPartChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _BodyPartChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : (Colors.grey.withValues(alpha: 0.3)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
