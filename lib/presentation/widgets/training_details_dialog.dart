import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/body_part_utils.dart';
import 'muscle_group_helper.dart';
import 'exercise_helper.dart';
import 'training_set_data.dart';
import '../../data/database/database.dart';
import '../../domain/entities/exercise_record_with_session.dart';
import '../providers/providers.dart';

class TrainingDetailsDialog extends ConsumerStatefulWidget {
  final ExerciseRecordWithSession exerciseRecord;
  final bool isDark;
  final AppLocalizations l10n;

  const TrainingDetailsDialog({
    required this.exerciseRecord,
    required this.isDark,
    required this.l10n,
  });

  @override
  ConsumerState<TrainingDetailsDialog> createState() => _TrainingDetailsDialogState();
}

class _TrainingDetailsDialogState extends ConsumerState<TrainingDetailsDialog> {
  bool _isEditing = false;
  bool _isBodyPartExpanded = false; // 控制部位选择器折叠状态
  late List<TrainingSetData> _sets;
  late TextEditingController _exerciseNameController;
  String? _selectedBodyPartId;

  @override
  void initState() {
    super.initState();
    _sets = widget.exerciseRecord.sets
        .map((s) => TrainingSetData(
              id: s.id,
              weight: s.weight,
              reps: s.reps,
            ))
        .toList();
    _exerciseNameController = TextEditingController(
      text: widget.exerciseRecord.exercise?.name ?? '',
    );
    // Get primary body part ID from bodyPartIds array
    if (widget.exerciseRecord.exercise != null) {
      final bodyPartIds = BodyPartUtils.parseBodyPartIds(widget.exerciseRecord.exercise!.bodyPartIds);
      _selectedBodyPartId = bodyPartIds.isNotEmpty ? bodyPartIds.first : null;
    }
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }

  // ===== Helper methods for editing =====

  /// Build body part chip (non-edit mode)
  Widget _buildBodyPartChip(String bodyPartName, Color muscleColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: muscleColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        bodyPartName,
        style: TextStyle(
          color: muscleColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build body part selector (edit mode) - collapsible
  Widget _buildBodyPartSelector() {
    final bodyPartsAsync = ref.watch(bodyPartsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.l10n.bodyPart,
              style: TextStyle(
                color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                fontSize: 11,
              ),
            ),
            // 展开/折叠按钮
            InkWell(
              onTap: () => setState(() => _isBodyPartExpanded = !_isBodyPartExpanded),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isBodyPartExpanded ? widget.l10n.collapse : widget.l10n.expand,
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 10,
                      ),
                    ),
                    Icon(
                      _isBodyPartExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: AppTheme.accent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        bodyPartsAsync.when(
          data: (bodyParts) {
            final locale = Localizations.localeOf(context).languageCode;
            
            // 找到当前选中的部位
            final selectedBodyPart = bodyParts.where((bp) => bp.id == _selectedBodyPartId).firstOrNull;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: _isBodyPartExpanded 
                  ? _buildAllBodyPartsSelector(bodyParts, locale)
                  : _buildSingleBodyPartDisplay(selectedBodyPart, locale),
            );
          },
          loading: () => const SizedBox(height: 32, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }

  /// 显示所有部位供选择（展开状态）
  Widget _buildAllBodyPartsSelector(List<BodyPart> bodyParts, String locale) {
    return Wrap(
      spacing: 6, runSpacing: 4,
      children: bodyParts.map((bp) {
        final bpMuscleGroup = MuscleGroupHelper.getMuscleGroupByName(bp.name);
        final bpColor = bpMuscleGroup != null 
            ? AppTheme.getMuscleColor(bpMuscleGroup) 
            : MuscleGroupHelper.getColorForBodyPart(bp.name);
        final isSelected = _selectedBodyPartId == bp.id;
        final displayName = bpMuscleGroup?.getLocalizedName(locale) ?? bp.name;
        return ChoiceChip(
          label: Text(displayName, style: const TextStyle(fontSize: 12)),
          selected: isSelected,
          selectedColor: bpColor.withOpacity(0.3),
          onSelected: (selected) {
            setState(() => _selectedBodyPartId = selected ? bp.id : null);
          },
        );
      }).toList(),
    );
  }

  /// 只显示当前选中的部位（折叠状态）
  Widget _buildSingleBodyPartDisplay(BodyPart? selectedBodyPart, String locale) {
    if (selectedBodyPart == null) {
      return Text(
        widget.l10n.selectBodyPart,
        style: TextStyle(
          color: widget.isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
          fontSize: 14,
        ),
      );
    }
    
    final bpMuscleGroup = MuscleGroupHelper.getMuscleGroupByName(selectedBodyPart.name);
    final bpColor = bpMuscleGroup != null 
        ? AppTheme.getMuscleColor(bpMuscleGroup) 
        : MuscleGroupHelper.getColorForBodyPart(selectedBodyPart.name);
    final displayName = bpMuscleGroup?.getLocalizedName(locale) ?? selectedBodyPart.name;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bpColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bpColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayName,
            style: TextStyle(
              color: bpColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.check_circle,
            size: 16,
            color: bpColor,
          ),
        ],
      ),
    );
  }

  /// Build exercise selector (edit mode)
  Widget _buildExerciseSelector() {
    final exercisesAsync = ref.watch(exercisesProvider);
    final filteredExercises = exercisesAsync.maybeWhen(
      data: (exercises) => _selectedBodyPartId != null
          ? exercises.where((e) {
              final bodyPartIds = BodyPartUtils.parseBodyPartIds(e.bodyPartIds);
              return bodyPartIds.contains(_selectedBodyPartId);
            }).toList()
          : exercises,
      orElse: () => <Exercise>[],
    );

    return InkWell(
      onTap: () => _showExerciseDialog(filteredExercises),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: Text(ExerciseHelper.getLocalizedName(_exerciseNameController.text, Localizations.localeOf(context).languageCode),
                style: TextStyle(color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight, fontSize: 14))),
            Icon(Icons.arrow_drop_down, size: 20, color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight),
          ],
        ),
      ),
    );
  }

  /// Show exercise selection dialog
  void _showExerciseDialog(List<Exercise> exercises) {
    final locale = Localizations.localeOf(context).languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.l10n.selectExercise),
        content: SizedBox(width: double.maxFinite, height: 300,
          child: exercises.isEmpty
              ? Center(child: Text(widget.l10n.noData))
              : ListView.builder(itemCount: exercises.length, itemBuilder: (context, index) =>
                  ListTile(title: Text(ExerciseHelper.getLocalizedName(exercises[index].name, locale)),
                    selected: _exerciseNameController.text == exercises[index].name,
                    onTap: () { _exerciseNameController.text = exercises[index].name; Navigator.pop(ctx); setState(() {}); }))),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(widget.l10n.cancel))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exerciseRecord;
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('yyyy-MM-dd');
    final locale = Localizations.localeOf(context).languageCode;

    // Get all body parts from the record
    final bodyPartsList = exercise.bodyParts.isNotEmpty 
        ? exercise.bodyParts 
        : (exercise.bodyPart != null ? [exercise.bodyPart!] : <BodyPart>[]);
    
    // Get localized body part names and colors
    final List<Widget> bodyPartWidgets = [];
    for (final bp in bodyPartsList) {
      final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bp.name);
      final displayName = muscleGroup?.getLocalizedName(locale) ?? bp.name;
      final color = muscleGroup != null 
          ? AppTheme.getMuscleColor(muscleGroup) 
          : MuscleGroupHelper.getColorForBodyPart(bp.name);
      bodyPartWidgets.add(_buildBodyPartChip(displayName, color));
    }
    
    // Get localized exercise name
    final rawExerciseName = exercise.exercise?.name;
    final displayExerciseName = rawExerciseName != null 
        ? ExerciseHelper.getLocalizedName(rawExerciseName, locale)
        : null;

    return Dialog(
      backgroundColor: widget.isDark ? AppTheme.cardDark : AppTheme.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.l10n.workoutDetails,
                  style: TextStyle(
                    color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date and time
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: widget.isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(exercise.session.startTime),
                  style: TextStyle(
                    color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: widget.isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  timeFormat.format(exercise.session.startTime),
                  style: TextStyle(
                    color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Body part
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Body part - edit mode shows selector, non-edit mode shows all body parts
                    _isEditing 
                        ? _buildBodyPartSelector() 
                        : (bodyPartWidgets.isNotEmpty 
                            ? Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: bodyPartWidgets,
                              )
                            : const SizedBox.shrink()),
                    const SizedBox(height: 8),

                    // Exercise
                    Text(widget.l10n.exercise, style: TextStyle(color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight, fontSize: 11)),
                    const SizedBox(height: 2),
                    _isEditing ? _buildExerciseSelector() : (displayExerciseName != null 
                        ? Text(displayExerciseName,
                            style: TextStyle(color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight, fontSize: 14, fontWeight: FontWeight.w500))
                        : const SizedBox.shrink()),
                    SizedBox(height: _isEditing ? 0 : 6),

                    // Sets
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(widget.l10n.sets, style: TextStyle(color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight, fontSize: 11)),
                      if (_isEditing) IconButton(onPressed: _addSet, icon: Icon(Icons.add_circle, color: AppTheme.accent, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints())
                    ]),
                    const SizedBox(height: 4),
                    _sets.isEmpty
                        ? Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Center(child: Text(widget.l10n.noData, style: TextStyle(color: widget.isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight, fontSize: 12))))
                        : ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _sets.length, itemBuilder: (context, index) => _buildSetItem(_sets[index], index)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isEditing) ...[
                  // Delete button in non-edit mode - same style as edit button
                  OutlinedButton.icon(
                    onPressed: _showDeleteConfirmDialog,
                    icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                    label: Text(widget.l10n.delete, style: const TextStyle(fontSize: 12, color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const Spacer(),
                ],
                if (_isEditing) ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _sets = widget.exerciseRecord.sets
                            .map((s) => TrainingSetData(
                                  id: s.id,
                                  weight: s.weight,
                                  reps: s.reps,
                                ))
                            .toList();
                        _exerciseNameController.text = widget.exerciseRecord.exercise?.name ?? '';
                        // Get primary body part ID from bodyPartIds array
                        if (widget.exerciseRecord.exercise != null) {
                          final bodyPartIds = BodyPartUtils.parseBodyPartIds(widget.exerciseRecord.exercise!.bodyPartIds);
                          _selectedBodyPartId = bodyPartIds.isNotEmpty ? bodyPartIds.first : null;
                        }
                      });
                    },
                    child: Text(widget.l10n.cancel, style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: _saveChanges,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: AppTheme.primaryDark,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(widget.l10n.save, style: const TextStyle(fontSize: 12)),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    icon: const Icon(Icons.edit, size: 14),
                    label: Text(widget.l10n.edit, style: const TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 微型滚轮选择器 - 用于编辑视图中的重量和次数选择
  Widget _buildMiniWheelPicker({
    required double value,
    required double minValue,
    required double maxValue,
    required double step,
    required bool isWeight,
    required ValueChanged<double> onChanged,
  }) {
    // 生成滚轮选项列表
    final List<double> values = [];
    for (double v = minValue; v <= maxValue; v += step) {
      values.add(v);
    }
    
    // 计算初始索引
    int initialIndex = ((value - minValue) / step).round().clamp(0, values.length - 1);
    
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.cardDark.withOpacity(0.5) : AppTheme.cardLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isDark 
              ? AppTheme.secondaryDark.withOpacity(0.3) 
              : AppTheme.secondaryLight.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // 微调按钮
          SizedBox(
            width: 24,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    final currentIndex = values.indexOf(value);
                    if (currentIndex > 0) {
                      onChanged(values[currentIndex - 1]);
                    }
                  },
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 16,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 2),
                InkWell(
                  onTap: () {
                    final currentIndex = values.indexOf(value);
                    if (currentIndex < values.length - 1) {
                      onChanged(values[currentIndex + 1]);
                    }
                  },
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
          // 滚轮选择器
          Expanded(
            child: Stack(
              children: [
                // 选中高亮
                Center(
                  child: Container(
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                // 滚轮
                ListWheelScrollView.useDelegate(
                  itemExtent: 28,
                  perspective: 0.005,
                  diameterRatio: 1.2,
                  physics: const FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(initialItem: initialIndex),
                  onSelectedItemChanged: (index) {
                    onChanged(values[index]);
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: values.length,
                    builder: (context, index) {
                      final v = values[index];
                      final isSelected = v == value;
                      return Center(
                        child: Text(
                          isWeight ? _formatWeight(v) : v.toInt().toString(),
                          style: TextStyle(
                            fontSize: isSelected ? 14 : 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected 
                                ? AppTheme.accent 
                                : (widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // 单位标签 - 只显示kg，reps不显示文本
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text(
              isWeight ? 'kg' : '',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化重量显示
  String _formatWeight(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }

  Widget _buildSetItem(TrainingSetData set, int index) {
    if (_isEditing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.only(left: 0, right: 0, top: 1, bottom: 1),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Set number - 最左边
            Container(
              width: 24,
              height: 24,

              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Weight wheel picker - 进一步加宽
            Expanded(
              flex: 10,
              child: _buildMiniWheelPicker(
                value: set.weight,
                minValue: 5,
                maxValue: 300,
                step: 0.5,
                isWeight: true,
                onChanged: (value) {
                  set.weight = value;
                },
              ),
            ),
            const SizedBox(width: 4),
            // Reps wheel picker - 进一步加宽
            Expanded(
              flex: 8,
              child: _buildMiniWheelPicker(
                value: set.reps.toDouble(),
                minValue: 1,
                maxValue: 100,
                step: 1,
                isWeight: false,
                onChanged: (value) {
                  set.reps = value.toInt();
                },
              ),
            ),
            // Delete button - 最右边，紧贴边缘
            IconButton(
              onPressed: () => _deleteSet(index),
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red.shade400,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
      );
    }

    // Display mode
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Set number
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Weight and reps
          Text(
            '${set.weight} kg x ${set.reps}',
            style: TextStyle(
              color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _addSet() {
    // Get the last set's values for inheritance
    double defaultWeight = 20.0;
    int defaultReps = 8;

    if (_sets.isNotEmpty) {
      // Inherit from the last set
      final lastSet = _sets.last;
      defaultWeight = lastSet.weight;
      defaultReps = lastSet.reps;
    }

    // Generate unique ID using UUID
    const uuid = Uuid();
    final newId = uuid.v4();

    // Directly add a new set item to the list
    setState(() {
      _sets.add(TrainingSetData(
        id: newId,
        weight: defaultWeight,
        reps: defaultReps,
      ));
    });
  }

  void _deleteSet(int index) {
    setState(() {
      _sets.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    final db = ref.read(databaseProvider);

    try {
      // If this is a body-part-only record, don't allow editing exercise
      if (widget.exerciseRecord.exercise == null) {
        // Just save the sets
        await _saveSetsOnly();
        return;
      }

      // Update exercise name and body part if changed
      final newName = _exerciseNameController.text.trim();
      // Get new bodyPartIds JSON array
      final newBodyPartIds = _selectedBodyPartId != null 
          ? '["${_selectedBodyPartId}"]' 
          : widget.exerciseRecord.exercise!.bodyPartIds;
      
      if (newName != widget.exerciseRecord.exercise!.name || 
          newBodyPartIds != widget.exerciseRecord.exercise!.bodyPartIds) {
        await db.updateExercise(
          widget.exerciseRecord.exercise!.id,
          name: newName,
          bodyPartIds: newBodyPartIds,
        );
      }

      // Update sets
      final originalSets = widget.exerciseRecord.sets;

      // Delete sets that were removed
      for (final originalSet in originalSets) {
        final stillExists = _sets.any((s) => s.id == originalSet.id);
        if (!stillExists) {
          await db.deleteSetRecord(originalSet.id);
        }
      }

      // Update or insert sets
      for (int i = 0; i < _sets.length; i++) {
        final set = _sets[i];
        final existingSet = originalSets.where((s) => s.id == set.id).firstOrNull;

        if (existingSet != null) {
          // Update existing set
          await db.updateSetRecord(
            set.id,
            weight: set.weight,
            reps: set.reps,
            orderIndex: i,
          );
        } else {
          // Insert new set
          await db.insertSetRecord(SetRecordsCompanion.insert(
            id: set.id,
            exerciseRecordId: widget.exerciseRecord.record.id,
            weight: set.weight,
            reps: set.reps,
            orderIndex: i,
          ));
        }
      }

      // Refresh data
      ref.invalidate(sessionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l10n.saved),
            backgroundColor: AppTheme.accent,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Save only sets for body-part-only records (no exercise editing)
  Future<void> _saveSetsOnly() async {
    final db = ref.read(databaseProvider);

    try {
      final originalSets = widget.exerciseRecord.sets;

      // Delete sets that were removed
      for (final originalSet in originalSets) {
        final stillExists = _sets.any((s) => s.id == originalSet.id);
        if (!stillExists) {
          await db.deleteSetRecord(originalSet.id);
        }
      }

      // Update or insert sets
      for (int i = 0; i < _sets.length; i++) {
        final set = _sets[i];
        final existingSet = originalSets.where((s) => s.id == set.id).firstOrNull;

        if (existingSet != null) {
          // Update existing set
          await db.updateSetRecord(
            set.id,
            weight: set.weight,
            reps: set.reps,
            orderIndex: i,
          );
        } else {
          // Insert new set
          await db.insertSetRecord(SetRecordsCompanion.insert(
            id: set.id,
            exerciseRecordId: widget.exerciseRecord.record.id,
            weight: set.weight,
            reps: set.reps,
            orderIndex: i,
          ));
        }
      }

      // Refresh data
      ref.invalidate(sessionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l10n.saved),
            backgroundColor: AppTheme.accent,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.l10n.delete),
        content: Text(widget.l10n.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(widget.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _performDelete();
            },
            child: Text(
              widget.l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Perform soft delete
  Future<void> _performDelete() async {
    final db = ref.read(databaseProvider);

    try {
      // Get session ID before deletion
      final sessionId = widget.exerciseRecord.record.sessionId;
      
      // Soft delete the exercise record and cascade delete sets
      await db.softDeleteExerciseRecordCascade(widget.exerciseRecord.record.id);

      // Check if session has any remaining records (excluding deleted)
      final remainingRecords = await db.getRecordsBySession(sessionId);
      
      // If no remaining records, delete the session
      if (remainingRecords.isEmpty) {
        await db.deleteSession(sessionId);
      }

      // Refresh data
      ref.invalidate(sessionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l10n.deleteSuccess),
            backgroundColor: AppTheme.accent,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
