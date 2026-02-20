import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/database.dart';
import '../providers/providers.dart';

// State for the workout session
class WorkoutSessionState {
  final String? sessionId;
  final DateTime startTime;
  final List<ExerciseInSession> exercises;
  final bool isActive;

  WorkoutSessionState({
    this.sessionId,
    required this.startTime,
    this.exercises = const [],
    this.isActive = false,
  });

  WorkoutSessionState copyWith({
    String? sessionId,
    DateTime? startTime,
    List<ExerciseInSession>? exercises,
    bool? isActive,
  }) {
    return WorkoutSessionState(
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      exercises: exercises ?? this.exercises,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ExerciseInSession {
  final String exerciseRecordId;
  final Exercise exercise;
  final BodyPart? bodyPart;
  final List<SetInSession> sets;

  ExerciseInSession({
    required this.exerciseRecordId,
    required this.exercise,
    this.bodyPart,
    this.sets = const [],
  });

  ExerciseInSession copyWith({
    String? exerciseRecordId,
    Exercise? exercise,
    BodyPart? bodyPart,
    List<SetInSession>? sets,
  }) {
    return ExerciseInSession(
      exerciseRecordId: exerciseRecordId ?? this.exerciseRecordId,
      exercise: exercise ?? this.exercise,
      bodyPart: bodyPart ?? this.bodyPart,
      sets: sets ?? this.sets,
    );
  }
}

class SetInSession {
  final String setRecordId;
  final double weight;
  final int reps;
  final int orderIndex;

  SetInSession({
    required this.setRecordId,
    required this.weight,
    required this.reps,
    required this.orderIndex,
  });
}

final workoutSessionProvider = StateNotifierProvider<WorkoutSessionNotifier, WorkoutSessionState>((ref) {
  return WorkoutSessionNotifier(ref);
});

class WorkoutSessionNotifier extends StateNotifier<WorkoutSessionState> {
  final Ref _ref;

  WorkoutSessionNotifier(this._ref) : super(WorkoutSessionState(startTime: DateTime.now().toUtc()));

  Future<void> startNewSession() async {
    final db = _ref.read(databaseProvider);
    final now = DateTime.now().toUtc();
    
    // Check if there's already a session for today
    final sessions = await db.getAllSessions();
    final today = DateTime.now();
    final todaySession = sessions.where((s) =>
      s.startTime.year == today.year &&
      s.startTime.month == today.month &&
      s.startTime.day == today.day
    ).firstOrNull;
    
    if (todaySession != null) {
      // Use existing session for today
      state = WorkoutSessionState(
        sessionId: todaySession.id,
        startTime: todaySession.startTime,
        isActive: true,
      );
      return;
    }
    
    // Create new session
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insertSession(WorkoutSessionsCompanion.insert(
      id: sessionId,
      startTime: now,
      createdAt: now,
    ));

    state = WorkoutSessionState(
      sessionId: sessionId,
      startTime: now,
      isActive: true,
    );
  }

  Future<void> addExercise(Exercise exercise) async {
    if (state.sessionId == null) return;

    final db = _ref.read(databaseProvider);
    final recordId = DateTime.now().millisecondsSinceEpoch.toString();

    await db.insertExerciseRecord(ExerciseRecordsCompanion.insert(
      id: recordId,
      sessionId: state.sessionId!,
      exerciseId: exercise.id,
    ));

    final bodyPart = await db.getBodyPartById(exercise.bodyPartId);

    final newExercise = ExerciseInSession(
      exerciseRecordId: recordId,
      exercise: exercise,
      bodyPart: bodyPart,
    );

    state = state.copyWith(
      exercises: [...state.exercises, newExercise],
    );
  }

  Future<void> addSet(int exerciseIndex, double weight, int reps) async {
    if (state.sessionId == null) return;
    if (exerciseIndex >= state.exercises.length) return;

    final exerciseInSession = state.exercises[exerciseIndex];
    final db = _ref.read(databaseProvider);
    final setId = DateTime.now().millisecondsSinceEpoch.toString();
    final orderIndex = exerciseInSession.sets.length;

    await db.insertSetRecord(SetRecordsCompanion.insert(
      id: setId,
      exerciseRecordId: exerciseInSession.exerciseRecordId,
      weight: weight,
      reps: reps,
      orderIndex: orderIndex,
    ));

    final newSet = SetInSession(
      setRecordId: setId,
      weight: weight,
      reps: reps,
      orderIndex: orderIndex,
    );

    final updatedExercises = [...state.exercises];
    updatedExercises[exerciseIndex] = exerciseInSession.copyWith(
      sets: [...exerciseInSession.sets, newSet],
    );

    state = state.copyWith(exercises: updatedExercises);
  }

  Future<void> deleteSet(int exerciseIndex, int setIndex) async {
    if (exerciseIndex >= state.exercises.length) return;

    final exerciseInSession = state.exercises[exerciseIndex];
    if (setIndex >= exerciseInSession.sets.length) return;

    final setToDelete = exerciseInSession.sets[setIndex];
    final db = _ref.read(databaseProvider);

    await db.deleteSetRecord(setToDelete.setRecordId);

    final updatedSets = [...exerciseInSession.sets];
    updatedSets.removeAt(setIndex);

    // Update order indices
    for (var i = 0; i < updatedSets.length; i++) {
      if (updatedSets[i].orderIndex != i) {
        final newSet = SetInSession(
          setRecordId: updatedSets[i].setRecordId,
          weight: updatedSets[i].weight,
          reps: updatedSets[i].reps,
          orderIndex: i,
        );
        updatedSets[i] = newSet;
      }
    }

    final updatedExercises = [...state.exercises];
    updatedExercises[exerciseIndex] = exerciseInSession.copyWith(sets: updatedSets);

    state = state.copyWith(exercises: updatedExercises);
  }

  Future<void> deleteExercise(int exerciseIndex) async {
    if (exerciseIndex >= state.exercises.length) return;

    final exerciseInSession = state.exercises[exerciseIndex];
    final db = _ref.read(databaseProvider);

    // Delete all sets
    await db.deleteSetsByExerciseRecord(exerciseInSession.exerciseRecordId);
    // Delete exercise record
    await db.deleteExerciseRecord(exerciseInSession.exerciseRecordId);

    final updatedExercises = [...state.exercises];
    updatedExercises.removeAt(exerciseIndex);

    state = state.copyWith(exercises: updatedExercises);
  }

  Future<void> endSession() async {
    if (state.sessionId != null) {
      // Delete empty session if no exercises
      if (state.exercises.isEmpty) {
        final db = _ref.read(databaseProvider);
        await db.deleteSession(state.sessionId!);
      }
    }

    state = WorkoutSessionState(startTime: DateTime.now().toUtc());
  }
}

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sessionState = ref.watch(workoutSessionProvider);
    final bodyPartsAsync = ref.watch(bodyPartsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.today),
      ),
      body: sessionState.isActive
          ? _ActiveWorkoutView(sessionState: sessionState)
          : _NoWorkoutView(bodyPartsAsync: bodyPartsAsync, l10n: l10n),
      floatingActionButton: sessionState.isActive
          ? FloatingActionButton.extended(
              onPressed: () async {
                await ref.read(workoutSessionProvider.notifier).endSession();
                ref.invalidate(sessionsProvider);
              },
              icon: const Icon(Icons.save),
              label: Text(l10n.save),
            )
          : FloatingActionButton.extended(
              onPressed: () => _showBodyPartSelection(context, ref),
              icon: const Icon(Icons.add),
              label: Text(l10n.newSession),
            ),
    );
  }

  void _showBodyPartSelection(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final bodyPartsAsync = ref.read(bodyPartsProvider);
    
    bodyPartsAsync.whenData((bodyParts) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, scrollController) => _BodyPartSelectSheet(
            scrollController: scrollController,
            bodyParts: bodyParts,
            l10n: l10n,
            onBodyPartSelected: (bodyPartId) async {
              // Create session if not exists
              final notifier = ref.read(workoutSessionProvider.notifier);
              final currentState = ref.read(workoutSessionProvider);
              if (!currentState.isActive) {
                await notifier.startNewSession();
              }
              
              // Directly add body part as exercise to session
              final db = ref.read(databaseProvider);
              final exerciseId = DateTime.now().millisecondsSinceEpoch.toString();
              await db.insertExercise(ExercisesCompanion.insert(
                id: exerciseId,
                name: bodyParts.firstWhere((bp) => bp.id == bodyPartId).name,
                bodyPartId: bodyPartId,
                createdAt: DateTime.now().toUtc(),
              ));
              ref.invalidate(exercisesProvider);
              
              // Get the new exercise and add to session
              final exercise = await db.getExerciseById(exerciseId);
              if (exercise != null && context.mounted) {
                await notifier.addExercise(exercise);
                Navigator.pop(sheetContext);
              }
            },
          ),
        ),
      );
    });
  }
}

class _NoWorkoutView extends ConsumerWidget {
  final AsyncValue<List<BodyPart>> bodyPartsAsync;
  final AppLocalizations l10n;

  const _NoWorkoutView({required this.bodyPartsAsync, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return sessionsAsync.when(
      data: (sessions) {
        // Filter today's sessions
        final today = DateTime.now();
        final todaySessions = sessions.where((s) =>
          s.startTime.year == today.year &&
          s.startTime.month == today.month &&
          s.startTime.day == today.day
        ).toList();

        if (todaySessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noSessions,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.newSession,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        // Show today's sessions
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: todaySessions.length,
          itemBuilder: (context, index) {
            return _TodaySessionCard(
              session: todaySessions[index],
              isDark: isDark,
              l10n: l10n,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _TodaySessionCard extends ConsumerWidget {
  final WorkoutSession session;
  final bool isDark;
  final AppLocalizations l10n;

  const _TodaySessionCard({
    required this.session,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(_recordsProvider(session.id));
    final bodyPartsAsync = ref.watch(_sessionBodyPartsProvider(session.id));
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Show body parts in primary position
                Expanded(
                  child: bodyPartsAsync.when(
                    data: (bodyParts) {
                      if (bodyParts.isEmpty) {
                        return Text(
                          l10n.noData,
                          style: Theme.of(context).textTheme.titleMedium,
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: bodyParts.map((bp) => Text(
                          bp,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.accent,
                          ),
                        )).toList(),
                      );
                    },
                    loading: () => const Text('...'),
                    error: (_, __) => Text(l10n.noData),
                  ),
                ),
                // Time in secondary position
                Row(
                  children: [
                    Text(
                      timeFormat.format(session.startTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditSessionDialog(context, ref),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            recordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return Text(
                    l10n.noData,
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return Column(
                  children: records.map((record) {
                    return _ExerciseRecordTile(
                      record: record,
                      isDark: isDark,
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSessionDialog(BuildContext context, WidgetRef ref) {
    // Show edit bottom sheet with session details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _EditSessionSheet(
          scrollController: scrollController,
          session: session,
          l10n: l10n,
        ),
      ),
    );
  }
}

class _ExerciseRecordTile extends ConsumerWidget {
  final ExerciseRecord record;
  final bool isDark;

  const _ExerciseRecordTile({
    required this.record,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(_exerciseProvider(record.exerciseId));
    final setsAsync = ref.watch(_setsProvider(record.id));

    return exerciseAsync.when(
      data: (exercise) {
        if (exercise == null) return const SizedBox.shrink();
        return setsAsync.when(
          data: (sets) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  ...sets.map((set) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Row(
                      children: [
                        Text('${set.weight} kg x ${set.reps}'),
                        const Spacer(),
                        Text(
                          '${(set.weight * set.reps).toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _EditSessionSheet extends ConsumerWidget {
  final ScrollController scrollController;
  final WorkoutSession session;
  final AppLocalizations l10n;

  const _EditSessionSheet({
    required this.scrollController,
    required this.session,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(_recordsProvider(session.id));

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
            l10n.sessionDetails,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: recordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return Center(child: Text(l10n.noData));
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return _EditableExerciseCard(
                      record: records[index],
                      l10n: l10n,
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showDeleteSessionDialog(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(l10n.delete),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSessionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.no),
          ),
          FilledButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              final records = await db.getRecordsBySession(session.id);
              for (final record in records) {
                await db.deleteSetsByExerciseRecord(record.id);
              }
              await db.deleteRecordsBySession(session.id);
              await db.deleteSession(session.id);
              ref.invalidate(sessionsProvider);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
              }
            },
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }
}

class _EditableExerciseCard extends ConsumerWidget {
  final ExerciseRecord record;
  final AppLocalizations l10n;

  const _EditableExerciseCard({
    required this.record,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(_exerciseProvider(record.exerciseId));
    final setsAsync = ref.watch(_setsProvider(record.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            exerciseAsync.when(
              data: (exercise) => Text(
                exercise?.name ?? 'Unknown',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              loading: () => const Text('...'),
              error: (_, __) => const Text('Error'),
            ),
            const Divider(),
            setsAsync.when(
              data: (sets) {
                return Column(
                  children: sets.asMap().entries.map((entry) {
                    final setIndex = entry.key;
                    final set = entry.value;
                    return _EditableSetRow(
                      set: set,
                      setIndex: setIndex,
                      recordId: record.id,
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
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
    final weightController = TextEditingController(text: '0');
    final repsController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addSets),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: l10n.weight),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: repsController,
              decoration: InputDecoration(labelText: l10n.reps),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final weight = double.tryParse(weightController.text) ?? 0;
              final reps = int.tryParse(repsController.text) ?? 0;
              if (weight > 0 && reps > 0) {
                final db = ref.read(databaseProvider);
                final sets = await db.getSetsByExerciseRecord(record.id);
                await db.insertSetRecord(SetRecordsCompanion.insert(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  exerciseRecordId: record.id,
                  weight: weight,
                  reps: reps,
                  orderIndex: sets.length,
                ));
                ref.invalidate(_setsProvider(record.id));
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _EditableSetRow extends ConsumerWidget {
  final SetRecord set;
  final int setIndex;
  final String recordId;

  const _EditableSetRow({
    required this.set,
    required this.setIndex,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            '${(set.weight * set.reps).toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await db.deleteSetRecord(set.id);
              ref.invalidate(_setsProvider(recordId));
            },
          ),
        ],
      ),
    );
  }
}

final _recordsProvider = FutureProvider.family<List<ExerciseRecord>, String>((ref, sessionId) async {
  final db = ref.watch(databaseProvider);
  return db.getRecordsBySession(sessionId);
});

final _exerciseProvider = FutureProvider.family<Exercise?, String>((ref, exerciseId) async {
  final db = ref.watch(databaseProvider);
  return db.getExerciseById(exerciseId);
});

final _setsProvider = FutureProvider.family<List<SetRecord>, String>((ref, exerciseRecordId) async {
  final db = ref.watch(databaseProvider);
  return db.getSetsByExerciseRecord(exerciseRecordId);
});

// Provider to get body part names for a session
final _sessionBodyPartsProvider = FutureProvider.family<List<String>, String>((ref, sessionId) async {
  final db = ref.watch(databaseProvider);
  final records = await db.getRecordsBySession(sessionId);
  final bodyPartNames = <String>[];
  
  for (final record in records) {
    final exercise = await db.getExerciseById(record.exerciseId);
    if (exercise != null) {
      final bodyPart = await db.getBodyPartById(exercise.bodyPartId);
      if (bodyPart != null && !bodyPartNames.contains(bodyPart.name)) {
        bodyPartNames.add(bodyPart.name);
      }
    }
  }
  return bodyPartNames;
});

class _ActiveWorkoutView extends ConsumerWidget {
  final WorkoutSessionState sessionState;

  const _ActiveWorkoutView({required this.sessionState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final exercisesAsync = ref.watch(exercisesProvider);
    final bodyPartsAsync = ref.watch(bodyPartsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Exercises List
        ...sessionState.exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exerciseInSession = entry.value;
          return _ExerciseCard(
            exerciseInSession: exerciseInSession,
            exerciseIndex: index,
          );
        }),

        const SizedBox(height: 16),

        // Add Exercise Button - simplified flow
        OutlinedButton.icon(
          onPressed: () => _showSimplifiedAddExercise(context, ref, exercisesAsync, bodyPartsAsync, l10n),
          icon: const Icon(Icons.add),
          label: Text(l10n.addExercise),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  void _showSimplifiedAddExercise(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Exercise>> exercisesAsync,
    AsyncValue<List<BodyPart>> bodyPartsAsync,
    AppLocalizations l10n,
  ) {
    bodyPartsAsync.whenData((bodyParts) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, scrollController) => _BodyPartSelectSheet(
            scrollController: scrollController,
            bodyParts: bodyParts,
            l10n: l10n,
            onBodyPartSelected: (bodyPartId) async {
              // Directly add body part as exercise to session
              final db = ref.read(databaseProvider);
              final exerciseId = DateTime.now().millisecondsSinceEpoch.toString();
              await db.insertExercise(ExercisesCompanion.insert(
                id: exerciseId,
                name: bodyParts.firstWhere((bp) => bp.id == bodyPartId).name,
                bodyPartId: bodyPartId,
                createdAt: DateTime.now().toUtc(),
              ));
              ref.invalidate(exercisesProvider);
              
              // Get the new exercise and add to session
              final exercise = await db.getExerciseById(exerciseId);
              if (exercise != null) {
                await ref.read(workoutSessionProvider.notifier).addExercise(exercise);
              }
              
              if (sheetContext.mounted) {
                Navigator.pop(sheetContext);
              }
            },
          ),
        ),
      );
    });
  }
}

class _ExerciseCard extends ConsumerWidget {
  final ExerciseInSession exerciseInSession;
  final int exerciseIndex;

  const _ExerciseCard({
    required this.exerciseInSession,
    required this.exerciseIndex,
  });

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
            // Exercise Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseInSession.exercise.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (exerciseInSession.bodyPart != null)
                        Text(
                          exerciseInSession.bodyPart!.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
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
              return _SetRow(
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
    final weightController = TextEditingController(text: '0');
    final repsController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addSets),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: l10n.weight),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: repsController,
              decoration: InputDecoration(labelText: l10n.reps),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text) ?? 0;
              final reps = int.tryParse(repsController.text) ?? 0;
              if (weight > 0 && reps > 0) {
                ref.read(workoutSessionProvider.notifier).addSet(
                      exerciseIndex,
                      weight,
                      reps,
                    );
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends ConsumerWidget {
  final SetInSession set;
  final int exerciseIndex;
  final int setIndex;

  const _SetRow({
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

class _AddExerciseSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final AsyncValue<List<BodyPart>> bodyPartsAsync;
  final AsyncValue<List<Exercise>> exercisesAsync;
  final AppLocalizations l10n;

  const _AddExerciseSheet({
    required this.scrollController,
    required this.bodyPartsAsync,
    required this.exercisesAsync,
    required this.l10n,
  });

  @override
  ConsumerState<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends ConsumerState<_AddExerciseSheet> {
  String? _selectedBodyPartId;
  String? _selectedExerciseId;

  @override
  Widget build(BuildContext context) {
    // Watch exercises provider to get updated list
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
          widget.bodyPartsAsync.when(
            data: (bodyParts) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...bodyParts.map((bp) => ChoiceChip(
                      label: Text(bp.name),
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
                  ? () {
                      final exercise = exercisesAsync.value?.firstWhere(
                        (e) => e.id == _selectedExerciseId,
                      );
                      if (exercise != null) {
                        ref.read(workoutSessionProvider.notifier).addExercise(exercise);
                        Navigator.pop(context);
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
    final l10n = AppLocalizations.of(context)!;
    final exercises = widget.exercisesAsync.value ?? [];
    final filtered = exercises.where((e) => e.bodyPartId == _selectedBodyPartId).toList();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addExerciseName),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.enterName,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                // Check for duplicate exercise names in the same body part
                final isDuplicate = filtered.any(
                  (e) => e.name.toLowerCase() == name.toLowerCase(),
                );
                if (isDuplicate) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text('Exercise "$name" already exists in this body part'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                final db = ref.read(databaseProvider);
                await db.insertExercise(ExercisesCompanion.insert(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  bodyPartId: _selectedBodyPartId!,
                  createdAt: DateTime.now().toUtc(),
                ));
                ref.invalidate(exercisesProvider);

                // Force rebuild to show the new exercise immediately
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                // Rebuild the sheet to show the new exercise
                if (context.mounted) {
                  (context as Element).markNeedsBuild();
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

// Simple body part selection sheet
class _BodyPartSelectSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<BodyPart> bodyParts;
  final AppLocalizations l10n;
  final Function(String bodyPartId) onBodyPartSelected;

  const _BodyPartSelectSheet({
    required this.scrollController,
    required this.bodyParts,
    required this.l10n,
    required this.onBodyPartSelected,
  });

  @override
  Widget build(BuildContext context) {
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
            l10n.selectBodyPart,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: bodyParts.length,
              itemBuilder: (context, index) {
                final bp = bodyParts[index];
                return ListTile(
                  title: Text(bp.name),
                  onTap: () => onBodyPartSelected(bp.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
