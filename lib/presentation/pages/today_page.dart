import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    
    // Check if there's a session within the last hour
    final now = DateTime.now().toUtc();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    
    // Get all sessions
    final allSessions = await db.getAllSessions();
    
    // Find a session that started within the last hour
    WorkoutSession? recentSession;
    for (final session in allSessions) {
      if (session.startTime.isAfter(oneHourAgo)) {
        recentSession = session;
        break;
      }
    }
    
    if (recentSession != null) {
      // Load existing exercises for the recent session
      final records = await db.getRecordsBySession(recentSession.id);
      final exercisesInSession = <ExerciseInSession>[];
      
      for (final record in records) {
        final exercise = await db.getExerciseById(record.exerciseId);
        if (exercise != null) {
          final bodyPart = await db.getBodyPartById(exercise.bodyPartId);
          final setRecords = await db.getSetsByExerciseRecord(record.id);
          final setsInSession = setRecords.map((s) => SetInSession(
            setRecordId: s.id,
            weight: s.weight,
            reps: s.reps,
            orderIndex: s.orderIndex,
          )).toList();
          exercisesInSession.add(ExerciseInSession(
            exerciseRecordId: record.id,
            exercise: exercise,
            bodyPart: bodyPart,
            sets: setsInSession,
          ));
        }
      }
      
      // Reuse the recent session with existing exercises
      state = WorkoutSessionState(
        sessionId: recentSession.id,
        startTime: recentSession.startTime,
        isActive: true,
        exercises: exercisesInSession,
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
    final sessionsAsync = ref.watch(sessionsProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    // Get today's sessions
    final todaySessions = sessionsAsync.maybeWhen(
      data: (sessions) {
        final now = DateTime.now();
        return sessions.where((s) =>
          s.startTime.year == now.year &&
          s.startTime.month == now.month &&
          s.startTime.day == now.day
        ).toList();
      },
      orElse: () => <WorkoutSession>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.today),
      ),
      body: sessionState.isActive
          ? _ActiveWorkoutView(sessionState: sessionState)
          : todaySessions.isNotEmpty
              ? _TodaySessionView(sessions: todaySessions)
              : _NoWorkoutView(bodyPartsAsync: bodyPartsAsync, l10n: l10n),
      floatingActionButton: sessionState.isActive
          ? null  // No FAB when session is active - auto-save on add
          : FloatingActionButton.extended(
              onPressed: () async {
                // Start session and show add exercise dialog
                await ref.read(workoutSessionProvider.notifier).startNewSession();
                if (context.mounted) {
                  _showAddExerciseSheet(context, ref, bodyPartsAsync, exercisesAsync, l10n);
                }
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.newSession),
            ),
    );
  }

  void _showAddExerciseSheet(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BodyPart>> bodyPartsAsync,
    AsyncValue<List<Exercise>> exercisesAsync,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _AddExerciseSheet(
          scrollController: scrollController,
          bodyPartsAsync: bodyPartsAsync,
          exercisesAsync: exercisesAsync,
          l10n: l10n,
          autoCloseOnAdd: true,
        ),
      ),
    );
  }
}

class _NoWorkoutView extends ConsumerWidget {
  final AsyncValue<List<BodyPart>> bodyPartsAsync;
  final AppLocalizations l10n;

  const _NoWorkoutView({required this.bodyPartsAsync, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}

// Display today's saved training sessions
class _TodaySessionView extends ConsumerWidget {
  final List<WorkoutSession> sessions;

  const _TodaySessionView({required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Sessions list
        ...sessions.asMap().entries.map((entry) {
          final index = entry.key;
          final session = entry.value;
          return _SavedSessionCard(
            session: session,
            sessionIndex: index,
            isDark: isDark,
            l10n: l10n,
          );
        }),
      ],
    );
  }
}

// Card displaying a saved session with training content as title
class _SavedSessionCard extends ConsumerWidget {
  final WorkoutSession session;
  final int sessionIndex;
  final bool isDark;
  final AppLocalizations l10n;

  const _SavedSessionCard({
    required this.session,
    required this.sessionIndex,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(_recordsProvider(session.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: recordsAsync.when(
          data: (records) => _buildContent(context, records, ref),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Error: $e'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ExerciseRecord> records, WidgetRef ref) {
    return FutureBuilder<_SessionDisplayData>(
      future: _getSessionDisplayData(records, ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final data = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Body parts on left (large), time on right (small gray)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main title: body parts
                Expanded(
                  child: Text(
                    data.bodyParts.join(' + '),
                    style: TextStyle(
                      color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Time on right
                Text(
                  _formatTime(session.startTime),
                  style: TextStyle(
                    color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Exercise details with sets
            ...data.exercises.map((exercise) => _ExerciseItemWidget(
              exercise: exercise,
              isDark: isDark,
              l10n: l10n,
            )),
          ],
        );
      },
    );
  }

  Future<_SessionDisplayData> _getSessionDisplayData(List<ExerciseRecord> records, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final Map<String, _ExerciseWithSets> exerciseMap = {};
    final Set<String> bodyParts = {};

    for (final record in records) {
      final exercise = await db.getExerciseById(record.exerciseId);
      if (exercise != null) {
        final bodyPart = await db.getBodyPartById(exercise.bodyPartId);
        if (bodyPart != null) {
          bodyParts.add(bodyPart.name);
        }
        
        // Get sets for this record
        final sets = await db.getSetsByExerciseRecord(record.id);
        
        if (exerciseMap.containsKey(exercise.id)) {
          // Add sets to existing exercise
          exerciseMap[exercise.id]!.sets.addAll(sets);
        } else {
          exerciseMap[exercise.id] = _ExerciseWithSets(
            name: exercise.name,
            bodyPart: bodyPart?.name ?? '',
            sets: sets,
          );
        }
      }
    }

    return _SessionDisplayData(
      bodyParts: bodyParts.toList(),
      exercises: exerciseMap.values.toList(),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// Data class for session display
class _SessionDisplayData {
  final List<String> bodyParts;
  final List<_ExerciseWithSets> exercises;

  _SessionDisplayData({
    required this.bodyParts,
    required this.exercises,
  });
}

class _ExerciseWithSets {
  final String name;
  final String bodyPart;
  final List<SetRecord> sets;

  _ExerciseWithSets({
    required this.name,
    required this.bodyPart,
    required this.sets,
  });
}

// Widget for displaying a single exercise with its sets
class _ExerciseItemWidget extends StatelessWidget {
  final _ExerciseWithSets exercise;
  final bool isDark;
  final AppLocalizations l10n;

  const _ExerciseItemWidget({
    required this.exercise,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name
          Text(
            exercise.name,
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Sets - only show if there are sets
          if (exercise.sets.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: exercise.sets.map((set) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${set.weight}kg x ${set.reps}',
                    style: TextStyle(
                      color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

final _recordsProvider = FutureProvider.family<List<ExerciseRecord>, String>((ref, sessionId) async {
  final db = ref.watch(databaseProvider);
  return db.getRecordsBySession(sessionId);
});

class _ActiveWorkoutView extends ConsumerStatefulWidget {
  final WorkoutSessionState sessionState;

  const _ActiveWorkoutView({required this.sessionState});

  @override
  ConsumerState<_ActiveWorkoutView> createState() => _ActiveWorkoutViewState();
}

class _ActiveWorkoutViewState extends ConsumerState<_ActiveWorkoutView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exercisesAsync = ref.watch(exercisesProvider);
    final bodyPartsAsync = ref.watch(bodyPartsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header with done button
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.currentSession,
                style: TextStyle(
                  color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // End session and go back to main view
                  ref.read(workoutSessionProvider.notifier).endSession();
                  ref.invalidate(sessionsProvider);
                },
                icon: const Icon(Icons.check, size: 18),
                label: Text(l10n.done),
              ),
            ],
          ),
        ),
        
        // Exercises List
        if (widget.sessionState.exercises.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.addExercise,
                style: TextStyle(
                  color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ...widget.sessionState.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exerciseInSession = entry.value;
            return _ExerciseCard(
              exerciseInSession: exerciseInSession,
              exerciseIndex: index,
            );
          }),

        const SizedBox(height: 16),

        // Add Exercise Button
        OutlinedButton.icon(
          onPressed: () => _showAddExerciseSheet(context, ref, bodyPartsAsync, exercisesAsync, l10n),
          icon: const Icon(Icons.add),
          label: Text(l10n.addExercise),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  void _showAddExerciseSheet(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<BodyPart>> bodyPartsAsync,
    AsyncValue<List<Exercise>> exercisesAsync,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _AddExerciseSheet(
          scrollController: scrollController,
          bodyPartsAsync: bodyPartsAsync,
          exercisesAsync: exercisesAsync,
          l10n: l10n,
          autoCloseOnAdd: true,
        ),
      ),
    );
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
            // Exercise Header: BodyPart -> Exercise Name
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Body Part (e.g., Chest)
                      if (exerciseInSession.bodyPart != null)
                        Text(
                          exerciseInSession.bodyPart!.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
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
    final exercisesAsync = ref.read(exercisesProvider);
    final bodyPartsAsync = ref.read(bodyPartsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddSetSheet(
        bodyPartsAsync: bodyPartsAsync,
        exercisesAsync: exercisesAsync,
        l10n: l10n,
        exerciseIndex: exerciseIndex,
        existingExercise: exerciseInSession.exercise,
        existingBodyPart: exerciseInSession.bodyPart,
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
  final bool autoCloseOnAdd;

  const _AddExerciseSheet({
    required this.scrollController,
    required this.bodyPartsAsync,
    required this.exercisesAsync,
    required this.l10n,
    this.autoCloseOnAdd = false,
  });

  @override
  ConsumerState<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends ConsumerState<_AddExerciseSheet> {
  String? _selectedBodyPartId;
  String? _selectedExerciseId;

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
              child: widget.exercisesAsync.when(
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
                      final exercise = widget.exercisesAsync.value?.firstWhere(
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

// ============ Add Set Sheet with Body Part and Exercise Selection ============

class _AddSetSheet extends ConsumerStatefulWidget {
  final AsyncValue<List<BodyPart>> bodyPartsAsync;
  final AsyncValue<List<Exercise>> exercisesAsync;
  final AppLocalizations l10n;
  final int exerciseIndex;
  final Exercise? existingExercise;
  final BodyPart? existingBodyPart;

  const _AddSetSheet({
    required this.bodyPartsAsync,
    required this.exercisesAsync,
    required this.l10n,
    required this.exerciseIndex,
    this.existingExercise,
    this.existingBodyPart,
  });

  @override
  ConsumerState<_AddSetSheet> createState() => _AddSetSheetState();
}

class _AddSetSheetState extends ConsumerState<_AddSetSheet> {
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
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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

              // Body Part Selection
              Text(widget.l10n.selectBodyPart, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              widget.bodyPartsAsync.when(
                data: (bodyParts) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: bodyParts.map((bp) => ChoiceChip(
                    label: Text(bp.name),
                    selected: _selectedBodyPartId == bp.id,
                    onSelected: (selected) {
                      setState(() {
                        _selectedBodyPartId = selected ? bp.id : null;
                        // Clear exercise selection when body part changes
                        if (!selected) {
                          _selectedExerciseId = null;
                        }
                      });
                    },
                  )).toList(),
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
                  child: widget.exercisesAsync.when(
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
                        controller: scrollController,
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

              // Weight and Reps Input
              const SizedBox(height: 16),
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

              // Save Button
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
    // and valid weight and reps
    final weight = double.tryParse(_weightController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    return _selectedExerciseId != null && weight > 0 && reps > 0;
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
