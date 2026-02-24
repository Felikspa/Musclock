import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../providers/workout_session_provider.dart';
import 'muscle_group_helper.dart';
import 'exercise_helper.dart';
import 'wheel_picker_input.dart';

// ============ Exercise Record Card for Today Module ============

class TodayExerciseRecordCard extends ConsumerWidget {
  final ExerciseInSession exerciseInSession;
  final int exerciseIndex;

  const TodayExerciseRecordCard({
    super.key,
    required this.exerciseInSession,
    required this.exerciseIndex,
  });

  // Build colored chip for body part display (matching Plan page style)
  Widget _buildMuscleChip(String bodyPartName, String locale) {
    final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bodyPartName);
    final color = muscleGroup != null 
        ? AppTheme.getMuscleColor(muscleGroup) 
        : MuscleGroupHelper.getColorForBodyPart(bodyPartName);
    final displayName = muscleGroup?.getLocalizedName(locale) ?? bodyPartName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Header: BodyPart -> Exercise Name
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Body Parts with colored border (like Plan page) - display all
                      if (exerciseInSession.bodyParts.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: exerciseInSession.bodyParts
                              .map((bp) => _buildMuscleChip(bp.name, locale))
                              .toList(),
                        )
                      else if (exerciseInSession.bodyPart != null)
                        _buildMuscleChip(exerciseInSession.bodyPart!.name, locale),
                      // Exercise Name (only show if exercise exists)
                      if (exerciseInSession.exercise != null)
                        Text(
                          ExerciseHelper.getLocalizedName(exerciseInSession.exercise!.name, locale),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref.read(workoutSessionProvider.notifier).deleteExercise(exerciseIndex);
                  },
                ),
              ],
            ),
            const Divider(),

            // Sets
            ...exerciseInSession.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final set = entry.value;
              return SetRow(
                set: set,
                exerciseIndex: exerciseIndex,
                setIndex: setIndex,
              );
            }),

            // Add Set Button
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showAddSetDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addSets),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSetDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Get the last set's values for inheritance
    final sets = exerciseInSession.sets;
    double? defaultWeight;
    int? defaultReps;

    if (sets.isNotEmpty) {
      // Find the set with the highest orderIndex (last added set)
      final lastSet = sets.reduce((a, b) =>
          a.orderIndex > b.orderIndex ? a : b);
      defaultWeight = lastSet.weight;
      defaultReps = lastSet.reps;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddSetSheet(
        l10n: l10n,
        exerciseIndex: exerciseIndex,
        existingExercise: exerciseInSession.exercise,
        existingBodyPart: exerciseInSession.bodyPart,
        defaultWeight: defaultWeight,
        defaultReps: defaultReps,
      ),
    );
  }
}

// ============ Set Row ============

class SetRow extends ConsumerWidget {
  final SetInSession set;
  final int exerciseIndex;
  final int setIndex;

  const SetRow({
    super.key,
    required this.set,
    required this.exerciseIndex,
    required this.setIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            child: Text(
              '${set.orderIndex + 1}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Text('${set.weight} kg'),
          const SizedBox(width: 8),
          Text('x ${set.reps}'),
          const Spacer(),
          Text(
            '${(set.weight * set.reps).toStringAsFixed(1)} ${l10n.volume}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              ref.read(workoutSessionProvider.notifier).deleteSet(exerciseIndex, setIndex);
            },
          ),
        ],
      ),
    );
  }
}

// ============ Add Set Sheet with Body Part and Exercise Selection ============

class AddSetSheet extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final int exerciseIndex;
  final Exercise? existingExercise;
  final BodyPart? existingBodyPart;
  final double? defaultWeight;
  final int? defaultReps;
  final bool isForEditing;
  final void Function(double weight, int reps)? onSetAdded; // Callback for when set is added

  const AddSetSheet({
    super.key,
    required this.l10n,
    required this.exerciseIndex,
    this.existingExercise,
    this.existingBodyPart,
    this.defaultWeight,
    this.defaultReps,
    this.isForEditing = false,
    this.onSetAdded,
  });

  @override
  ConsumerState<AddSetSheet> createState() => AddSetSheetState();
}

class AddSetSheetState extends ConsumerState<AddSetSheet> {
  String? _selectedExerciseId;
  late double _weightValue;
  late int _repsValue;

  @override
  void initState() {
    super.initState();
    // Pre-select existing exercise and body part if available
    // Use inherited default values if provided, otherwise use defaults
    _weightValue = widget.defaultWeight ?? 20.0;
    _repsValue = widget.defaultReps ?? 8;

    if (widget.existingExercise != null) {
      _selectedExerciseId = widget.existingExercise!.id;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers directly so they update automatically when new data is added
    final exercisesAsync = ref.watch(exercisesProvider);
    final locale = Localizations.localeOf(context).languageCode;

    // If we have existing exercise from the session, use it directly
    final hasExistingExercise = widget.existingExercise != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                widget.l10n.addSets,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Exercise Selection (only show if no existing exercise)
              if (!hasExistingExercise) ...[
                Text(widget.l10n.selectExercise, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: exercisesAsync.when(
                    data: (exercises) {
                      if (exercises.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(widget.l10n.noData),
                              const SizedBox(height: 8),
                              Text(widget.l10n.addExercise),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          return ListTile(
                            title: Text(ExerciseHelper.getLocalizedName(exercise.name, locale)),
                            selected: _selectedExerciseId == exercise.id,
                            onTap: () {
                              setState(() {
                                _selectedExerciseId = exercise.id;
                              });
                            },
                          );
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, s) => Text('Error: $e'),
                  ),
                ),
              ] else ...[
                // Display existing exercise info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ExerciseHelper.getLocalizedName(widget.existingExercise!.name, locale),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Weight and Reps Wheel Pickers
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 13,
                    child: WheelPickerInput(
                      type: 'weight',
                      minValue: 5,
                      maxValue: 550,
                      step: 5,
                      defaultValue: _weightValue,
                      fineStep: 0.5,
                      label: widget.l10n.weight,
                      onChanged: (value) {
                        setState(() {
                          _weightValue = value.toDouble();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 10,
                    child: WheelPickerInput(
                      type: 'reps',
                      minValue: 1,
                      maxValue: 100,
                      step: 1,
                      defaultValue: _repsValue,
                      label: widget.l10n.reps,
                      onChanged: (value) {
                        setState(() {
                          _repsValue = value.toInt();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Save Button - allow save with just exercise selected
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canSave() ? () => _saveSet(context) : null,
                  child: Text(widget.l10n.save),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _canSave() {
    // Allow saving if we have an exercise (either existing or selected)
    // Weight and reps are optional - can be 0
    return _selectedExerciseId != null || widget.existingExercise != null;
  }

  void _saveSet(BuildContext context) async {
    final weight = _weightValue;
    final reps = _repsValue;

    // If callback is provided, use it instead of adding to workout session
    if (widget.onSetAdded != null) {
      widget.onSetAdded!(weight, reps);
      Navigator.pop(context);
      return;
    }

    // Allow saving if we have an exercise selected (weight/reps can be 0)
    if (_selectedExerciseId != null || widget.existingExercise != null) {
      // Get the exercise to add
      Exercise? exercise;
      if (_selectedExerciseId != null) {
        final exercisesAsync = ref.read(exercisesProvider);
        exercise = exercisesAsync.value?.firstWhere(
          (e) => e.id == _selectedExerciseId,
          orElse: () => Exercise(
            id: '',
            name: '',
            bodyPartIds: '[]',
            createdAt: DateTime.now(),
          ),
        );
      } else {
        exercise = widget.existingExercise;
      }

      if (exercise != null && exercise.id.isNotEmpty) {
        // Check if this exercise is already in the session
        final sessionState = ref.read(workoutSessionProvider);
        final existingIndex = sessionState.exercises.indexWhere(
          (e) => e.exercise?.id == exercise!.id,
        );

        if (existingIndex >= 0) {
          // Exercise already exists, add set to it
          ref.read(workoutSessionProvider.notifier).addSet(
            existingIndex,
            weight,
            reps,
          );
        } else {
          // New exercise, add it first then add set
          await ref.read(workoutSessionProvider.notifier).addExercise(exercise);
          // Find the new exercise index and add set
          final newState = ref.read(workoutSessionProvider);
          final newIndex = newState.exercises.indexWhere(
            (e) => e.exercise?.id == exercise!.id,
          );
          if (newIndex >= 0) {
            ref.read(workoutSessionProvider.notifier).addSet(
              newIndex,
              weight,
              reps,
            );
          }
        }

        // Close the sheet - user will see the updated session with new exercise if added
        Navigator.pop(context);

        // Show a snackbar to inform user about the new exercise added
        if (existingIndex < 0 && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${exercise.name} to session'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}
