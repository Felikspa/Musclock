import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import 'muscle_group_helper.dart';
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
  late List<_SetData> _sets;
  late TextEditingController _exerciseNameController;
  String? _selectedBodyPartId;

  @override
  void initState() {
    super.initState();
    _sets = widget.exerciseRecord.sets
        .map((s) => _SetData(
              id: s.id,
              weight: s.weight,
              reps: s.reps,
            ))
        .toList();
    _exerciseNameController = TextEditingController(
      text: widget.exerciseRecord.exercise.name,
    );
    _selectedBodyPartId = widget.exerciseRecord.exercise.bodyPartId;
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

  /// Build body part selector (edit mode)
  Widget _buildBodyPartSelector() {
    final bodyPartsAsync = ref.watch(bodyPartsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.l10n.bodyPart,
          style: TextStyle(
            color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        bodyPartsAsync.when(
          data: (bodyParts) => Wrap(
            spacing: 6, runSpacing: 4,
            children: bodyParts.map((bp) {
              final bpMuscleGroup = MuscleGroupHelper.getMuscleGroupByName(bp.name);
              final bpColor = AppTheme.getMuscleColor(bpMuscleGroup);
              final isSelected = _selectedBodyPartId == bp.id;
              return ChoiceChip(
                label: Text(bp.name, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                selectedColor: bpColor.withOpacity(0.3),
                onSelected: (selected) {
                  setState(() => _selectedBodyPartId = selected ? bp.id : null);
                },
              );
            }).toList(),
          ),
          loading: () => const SizedBox(height: 32, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }

  /// Build exercise selector (edit mode)
  Widget _buildExerciseSelector() {
    final exercisesAsync = ref.watch(exercisesProvider);
    final filteredExercises = exercisesAsync.maybeWhen(
      data: (exercises) => _selectedBodyPartId != null
          ? exercises.where((e) => e.bodyPartId == _selectedBodyPartId).toList()
          : exercises,
      orElse: () => <Exercise>[],
    );

    return InkWell(
      onTap: () => _showExerciseDialog(filteredExercises),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: Text(_exerciseNameController.text,
                style: TextStyle(color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight, fontSize: 16))),
            Icon(Icons.arrow_drop_down, color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight),
          ],
        ),
      ),
    );
  }

  /// Show exercise selection dialog
  void _showExerciseDialog(List<Exercise> exercises) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.l10n.selectExercise),
        content: SizedBox(width: double.maxFinite, height: 300,
          child: exercises.isEmpty
              ? Center(child: Text(widget.l10n.noData))
              : ListView.builder(itemCount: exercises.length, itemBuilder: (context, index) =>
                  ListTile(title: Text(exercises[index].name),
                    selected: _exerciseNameController.text == exercises[index].name,
                    onTap: () { _exerciseNameController.text = exercises[index].name; Navigator.pop(ctx); setState(() {}); }))),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(widget.l10n.cancel))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exerciseRecord;
    final bodyPartName = exercise.bodyPart?.name ?? '';
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Get muscle color
    final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bodyPartName);
    final muscleColor = AppTheme.getMuscleColor(muscleGroup);

    return Dialog(
      backgroundColor: widget.isDark ? AppTheme.cardDark : AppTheme.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: const EdgeInsets.all(20),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date and time
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: widget.isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(exercise.session.startTime),
                  style: TextStyle(
                    color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: widget.isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  timeFormat.format(exercise.session.startTime),
                  style: TextStyle(
                    color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Body part
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Body part - edit mode shows selector
                    _isEditing ? _buildBodyPartSelector() : _buildBodyPartChip(bodyPartName, muscleColor),
                    const SizedBox(height: 16),

                    // Exercise
                    Text(widget.l10n.exercise, style: TextStyle(color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight, fontSize: 12)),
                    const SizedBox(height: 4),
                    _isEditing ? _buildExerciseSelector() : Text(exercise.exercise.name,
                        style: TextStyle(color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight, fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),

                    // Sets
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(widget.l10n.sets, style: TextStyle(color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight, fontSize: 12)),
                      if (_isEditing) IconButton(onPressed: _addSet, icon: Icon(Icons.add_circle, color: AppTheme.accent, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints())
                    ]),
                    const SizedBox(height: 8),
                    _sets.isEmpty
                        ? Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Center(child: Text(widget.l10n.noData, style: TextStyle(color: widget.isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight, fontSize: 14))))
                        : ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _sets.length, itemBuilder: (context, index) => _buildSetItem(_sets[index], index)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isEditing) ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _sets = widget.exerciseRecord.sets
                            .map((s) => _SetData(
                                  id: s.id,
                                  weight: s.weight,
                                  reps: s.reps,
                                ))
                            .toList();
                        _exerciseNameController.text = widget.exerciseRecord.exercise.name;
                        _selectedBodyPartId = widget.exerciseRecord.exercise.bodyPartId;
                      });
                    },
                    child: Text(widget.l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saveChanges,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: AppTheme.primaryDark,
                    ),
                    child: Text(widget.l10n.save),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(widget.l10n.edit),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetItem(_SetData set, int index) {
    if (_isEditing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Set number
            Container(
              width: 28,
              height: 28,
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
            const SizedBox(width: 12),
            // Weight input
            Expanded(
              child: TextField(
                controller: TextEditingController(text: set.weight.toString()),
                onChanged: (value) {
                  set.weight = double.tryParse(value) ?? 0;
                },
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  suffixText: 'kg',
                  suffixStyle: TextStyle(
                    color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: widget.isDark ? AppTheme.cardDark : AppTheme.cardLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Reps input
            Expanded(
              child: TextField(
                controller: TextEditingController(text: set.reps.toString()),
                onChanged: (value) {
                  set.reps = int.tryParse(value) ?? 0;
                },
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  suffixText: 'reps',
                  suffixStyle: TextStyle(
                    color: widget.isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: widget.isDark ? AppTheme.cardDark : AppTheme.cardLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Delete button
            IconButton(
              onPressed: () => _deleteSet(index),
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.red.shade400,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
            width: 28,
            height: 28,
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
          const SizedBox(width: 12),
          // Weight and reps
          Text(
            '${set.weight} kg x ${set.reps} reps',
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
    setState(() {
      _sets.add(_SetData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        weight: 0,
        reps: 0,
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
      // Update exercise name and body part if changed
      final newName = _exerciseNameController.text.trim();
      final newBodyPartId = _selectedBodyPartId ?? widget.exerciseRecord.exercise.bodyPartId;
      
      if (newName != widget.exerciseRecord.exercise.name || 
          newBodyPartId != widget.exerciseRecord.exercise.bodyPartId) {
        await db.updateExercise(ExercisesCompanion(
          id: Value(widget.exerciseRecord.exercise.id),
          name: Value(newName),
          bodyPartId: Value(newBodyPartId),
          createdAt: Value(widget.exerciseRecord.exercise.createdAt),
        ));
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
          await db.updateSetRecord(SetRecordsCompanion(
            id: Value(set.id),
            exerciseRecordId: Value(existingSet.exerciseRecordId),
            weight: Value(set.weight),
            reps: Value(set.reps),
            orderIndex: Value(i),
          ));
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
}

class _SetData {
  String id;
  double weight;
  int reps;

  _SetData({
    required this.id,
    required this.weight,
    required this.reps,
  });
}
