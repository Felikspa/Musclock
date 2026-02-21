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
  String? _selectedBodyPartId;
  String? _selectedExerciseId;

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

          // Body Part Selection
          Text(widget.l10n.selectBodyPart, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          bodyPartsAsync.when(
            data: (bodyParts) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...bodyParts.map((bp) => ChoiceChip(
                      label: Text(
                        bp.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      selected: _selectedBodyPartId == bp.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedBodyPartId = selected ? bp.id : null;
                          _selectedExerciseId = null;
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

          // Exercise Selection
          if (_selectedBodyPartId != null) ...[
            Text(widget.l10n.selectExercise, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: exercisesAsync.when(
                data: (exercises) {
                  final filtered = exercises.where((e) => e.bodyPartId == _selectedBodyPartId).toList();
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
          ],

          // Add Button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedExerciseId != null
                  ? () async {
                      final exercise = exercisesAsync.value?.firstWhere(
                        (e) => e.id == _selectedExerciseId,
                      );
                      if (exercise != null) {
                        await ref.read(workoutSessionProvider.notifier).addExercise(exercise);
                        ref.invalidate(sessionsProvider);  // Refresh sessions list
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    }
                  : null,
              child: Text(widget.l10n.addExercise),
            ),
          ),
        ],
      ),
    );
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
