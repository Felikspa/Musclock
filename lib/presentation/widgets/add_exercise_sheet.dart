import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/database.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../providers/workout_session_provider.dart';

class AddExerciseSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final AppLocalizations l10n;
  final bool autoCloseOnAdd;

  const AddExerciseSheet({
    super.key,
    required this.scrollController,
    required this.l10n,
    this.autoCloseOnAdd = false,
  });

  @override
  ConsumerState<AddExerciseSheet> createState() => AddExerciseSheetState();
}

class AddExerciseSheetState extends ConsumerState<AddExerciseSheet> {
  // Support multi-select for body parts
  final Set<String> _selectedBodyPartIds = {};
  // Support multi-select for exercises
  final Set<String> _selectedExerciseIds = {};

  @override
  Widget build(BuildContext context) {
    // Watch providers directly so they update automatically when new data is added
    final bodyPartsAsync = ref.watch(bodyPartsProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            widget.l10n.addExercise,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Body Part Selection (Multi-select)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.l10n.selectBodyPart, style: Theme.of(context).textTheme.titleMedium),
              if (_selectedBodyPartIds.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedBodyPartIds.clear();
                      _selectedExerciseIds.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          bodyPartsAsync.when(
            data: (bodyParts) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...bodyParts.map((bp) => FilterChip(
                      label: Text(
                        bp.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      selected: _selectedBodyPartIds.contains(bp.id),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedBodyPartIds.add(bp.id);
                          } else {
                            _selectedBodyPartIds.remove(bp.id);
                            // Also remove exercises from this body part
                            _selectedExerciseIds.removeWhere((exerciseId) {
                              final exerciseList = exercisesAsync.value;
                              if (exerciseList == null) return false;
                              final exercise = exerciseList.firstWhere(
                                (e) => e.id == exerciseId,
                                orElse: () => Exercise(
                                  id: '',
                                  name: '',
                                  bodyPartId: '',
                                  createdAt: DateTime.now(),
                                ),
                              );
                              return exercise.bodyPartId == bp.id;
                            });
                          }
                        });
                      },
                    )),
                ActionChip(
                  label: Text(widget.l10n.addBodyPart),
                  onPressed: () => _showAddBodyPartDialog(context),
                ),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (e, s) => Text('Error: $e'),
          ),

          const SizedBox(height: 16),

          // Exercise Selection (Multi-select, filtered by selected body parts)
          if (_selectedBodyPartIds.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.l10n.selectExercise, style: Theme.of(context).textTheme.titleMedium),
                if (_selectedExerciseIds.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedExerciseIds.clear();
                      });
                    },
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: exercisesAsync.when(
                data: (exercises) {
                  // Filter exercises by selected body parts
                  final filtered = exercises
                      .where((e) => _selectedBodyPartIds.contains(e.bodyPartId))
                      .toList();
                  
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.l10n.noData),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showAddExerciseDialog(context),
                            icon: const Icon(Icons.add),
                            label: Text(widget.l10n.addExerciseName),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    controller: widget.scrollController,
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        return ListTile(
                          leading: const Icon(Icons.add),
                          title: Text(widget.l10n.addExerciseName),
                          onTap: () => _showAddExerciseDialog(context),
                        );
                      }
                      final exercise = filtered[index];
                      return CheckboxListTile(
                        title: Text(exercise.name),
                        value: _selectedExerciseIds.contains(exercise.id),
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedExerciseIds.add(exercise.id);
                            } else {
                              _selectedExerciseIds.remove(exercise.id);
                            }
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
          ],

          const SizedBox(height: 16),

          // Save Button - allow save with just body parts selected
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canSave()
                  ? () => _saveExercises(context, exercisesAsync)
                  : null,
              child: Text(widget.l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  bool _canSave() {
    // Allow saving if we have at least one body part selected
    return _selectedBodyPartIds.isNotEmpty;
  }

  void _saveExercises(BuildContext context, AsyncValue<List<Exercise>> exercisesAsync) async {
    final sessionState = ref.read(workoutSessionProvider);
    final bodyPartsAsync = ref.read(bodyPartsProvider);
    final exercises = exercisesAsync.value;
    final bodyParts = bodyPartsAsync.value;
    
    if (bodyParts == null) return;

    int addedCount = 0;

    // If exercises are selected, add them
    if (_selectedExerciseIds.isNotEmpty && exercises != null) {
      for (final exerciseId in _selectedExerciseIds) {
        final exercise = exercises.firstWhere(
          (e) => e.id == exerciseId,
          orElse: () => Exercise(
            id: '',
            name: '',
            bodyPartId: '',
            createdAt: DateTime.now(),
          ),
        );
        
        if (exercise.id.isEmpty) continue;

        // Check if exercise already exists in session
        final isDuplicate = sessionState.exercises.any(
          (e) => e.exercise?.id == exercise.id,
        );
        
        if (isDuplicate) {
          continue;
        }

        await ref.read(workoutSessionProvider.notifier).addExercise(exercise);
        addedCount++;
      }
    } else {
      // No exercises selected - just body parts
      // Add body-part-only entries (no specific exercise)
      for (final bodyPartId in _selectedBodyPartIds) {
        final bodyPart = bodyParts.firstWhere(
          (bp) => bp.id == bodyPartId,
          orElse: () => BodyPart(
            id: '',
            name: '',
            createdAt: DateTime.now(),
            isDeleted: false,
          ),
        );
        
        if (bodyPart.id.isEmpty) continue;

        // Add body-part-only entry
        await ref.read(workoutSessionProvider.notifier).addBodyPart(bodyPart);
        addedCount++;
      }
    }

    ref.invalidate(sessionsProvider);

    if (context.mounted) {
      if (addedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $addedCount item(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pop(context);
    }
  }

  void _showAddBodyPartDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.l10n.addBodyPart),
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
                await db.insertBodyPart(BodyPartsCompanion.insert(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  createdAt: DateTime.now().toUtc(),
                ));
                ref.invalidate(bodyPartsProvider);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(widget.l10n.save),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    if (_selectedBodyPartIds.isEmpty) return;

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
                // Add to all selected body parts
                for (final bodyPartId in _selectedBodyPartIds) {
                  await db.insertExercise(ExercisesCompanion.insert(
                    id: DateTime.now().millisecondsSinceEpoch.toString() + bodyPartId,
                    name: nameController.text,
                    bodyPartId: bodyPartId,
                    createdAt: DateTime.now().toUtc(),
                  ));
                }
                ref.invalidate(exercisesProvider);
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
