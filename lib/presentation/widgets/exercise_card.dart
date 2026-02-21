import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../providers/workout_session_provider.dart';
import 'muscle_group_helper.dart';

// ============ Exercise Card ============

class ExerciseCard extends ConsumerWidget {
  final ExerciseInSession exerciseInSession;
  final int exerciseIndex;

  const ExerciseCard({
    super.key,
    required this.exerciseInSession,
    required this.exerciseIndex,
  });

  // Build colored chip for body part display (matching Plan page style)
  Widget _buildMuscleChip(String bodyPartName) {
    final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bodyPartName);
    final color = AppTheme.getMuscleColor(muscleGroup);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Text(
        bodyPartName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

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
                      // Body Part with colored border (like Plan page)
                      if (exerciseInSession.bodyPart != null)
                        _buildMuscleChip(exerciseInSession.bodyPart!.name),
                      // Exercise Name (e.g., Benchpress)
                      Text(
                        exerciseInSession.exercise.name,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddSetSheet(
        l10n: l10n,
        exerciseIndex: exerciseIndex,
        existingExercise: exerciseInSession.exercise,
        existingBodyPart: exerciseInSession.bodyPart,
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

  const AddSetSheet({
    super.key,
    required this.l10n,
    required this.exerciseIndex,
    this.existingExercise,
    this.existingBodyPart,
  });

  @override
  ConsumerState<AddSetSheet> createState() => AddSetSheetState();
}

class AddSetSheetState extends ConsumerState<AddSetSheet> {
  String? _selectedBodyPartId;
  String? _selectedExerciseId;
  final _weightController = TextEditingController(text: '0');
  final _repsController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    // Pre-select existing exercise and body part if available
    if (widget.existingExercise != null) {
      _selectedExerciseId = widget.existingExercise!.id;
      _selectedBodyPartId = widget.existingExercise!.bodyPartId;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers directly so they update automatically when new data is added
    final exercisesAsync = ref.watch(exercisesProvider);

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
                            title: Text(exercise.name),
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
                        widget.existingExercise!.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Weight and Reps Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: widget.l10n.weight,
                        suffixText: 'kg',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      decoration: InputDecoration(
                        labelText: widget.l10n.reps,
                      ),
                      keyboardType: TextInputType.number,
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
    final weight = double.tryParse(_weightController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    
    if (_selectedExerciseId != null && weight > 0 && reps > 0) {
      // Check if we need to add a new exercise to the session
      final exercisesAsync = ref.read(exercisesProvider);
      final exercise = exercisesAsync.value?.firstWhere(
        (e) => e.id == _selectedExerciseId,
      );
      
      if (exercise != null) {
        // Check if this exercise is already in the session
        final sessionState = ref.read(workoutSessionProvider);
        final existingIndex = sessionState.exercises.indexWhere(
          (e) => e.exercise.id == exercise.id,
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
            (e) => e.exercise.id == exercise.id,
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

  void _showAddExerciseDialog(BuildContext context) {
    if (_selectedBodyPartId == null) return;

    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.l10n.addExerciseName),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: widget.l10n.enterName,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final db = ref.read(databaseProvider);
                await db.insertExercise(ExercisesCompanion.insert(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  bodyPartId: _selectedBodyPartId!,
                  createdAt: DateTime.now().toUtc(),
                ));
                ref.invalidate(exercisesProvider);
                // Select the newly created exercise
                final exercises = await db.getExercisesByBodyPart(_selectedBodyPartId!);
                if (exercises.isNotEmpty) {
                  setState(() {
                    _selectedExerciseId = exercises.last.id;
                  });
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(widget.l10n.save),
          ),
        ],
      ),
    );
  }
}
