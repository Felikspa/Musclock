import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/database/database.dart';
import '../../domain/entities/exercise_record_with_session.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../providers/workout_session_provider.dart';
import 'training_details_dialog.dart';

// Data class for session display
class SessionDisplayData {
  final List<String> bodyParts;
  final List<ExerciseWithSets> exercises;
  final DateTime? earliestTime;

  SessionDisplayData({
    required this.bodyParts,
    required this.exercises,
    this.earliestTime,
  });
}

class ExerciseWithSets {
  final String name;
  final String bodyPart;
  final List<SetRecord> sets;
  final ExerciseRecord record;

  ExerciseWithSets({
    required this.name,
    required this.bodyPart,
    required this.sets,
    required this.record,
  });
}

// Provider for fetching records by session
final _recordsProvider = FutureProvider.family<List<ExerciseRecord>, String>((ref, sessionId) async {
  final db = ref.watch(databaseProvider);
  return db.getRecordsBySession(sessionId);
});

// Display today's saved training sessions
class TodaySessionView extends ConsumerWidget {
  final List<WorkoutSession> sessions;

  const TodaySessionView({super.key, required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...sessions.asMap().entries.map((entry) {
          final index = entry.key;
          final session = entry.value;
          return SavedSessionCard(
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
class SavedSessionCard extends ConsumerWidget {
  final WorkoutSession session;
  final int sessionIndex;
  final bool isDark;
  final AppLocalizations l10n;

  const SavedSessionCard({
    super.key,
    required this.session,
    required this.sessionIndex,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(_recordsProvider(session.id));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
          width: 1,
        ),
      ),
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
    return FutureBuilder<SessionDisplayData>(
      future: _getSessionDisplayData(records, ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final data = snapshot.data!;
        
        final earliestTime = data.earliestTime ?? session.startTime;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    data.bodyParts.join(' + '),
                    style: TextStyle(
                      color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  _formatTime(earliestTime),
                  style: TextStyle(
                    color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            ...data.exercises.map((exercise) => ExerciseItemWidget(
              exercise: exercise,
              isDark: isDark,
              l10n: l10n,
              onTap: () => _showExerciseDetailsDialog(context, ref, exercise),
            )),
          ],
        );
      },
    );
  }

  Future<SessionDisplayData> _getSessionDisplayData(List<ExerciseRecord> records, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final Map<String, ExerciseWithSets> exerciseMap = {};
    final Set<String> bodyParts = {};
    DateTime? earliestTime;

    for (final record in records) {
      final exercise = await db.getExerciseById(record.exerciseId);
      if (exercise != null) {
        final bodyPart = await db.getBodyPartById(exercise.bodyPartId);
        if (bodyPart != null) {
          bodyParts.add(bodyPart.name);
        }
        
        final sets = await db.getSetsByExerciseRecord(record.id);
        
        if (exerciseMap.containsKey(exercise.id)) {
          exerciseMap[exercise.id]!.sets.addAll(sets);
        } else {
          exerciseMap[exercise.id] = ExerciseWithSets(
            name: exercise.name,
            bodyPart: bodyPart?.name ?? '',
            sets: sets,
            record: record,
          );
        }
        
        if (earliestTime == null || session.startTime.isBefore(earliestTime!)) {
          earliestTime = session.startTime;
        }
      }
    }

    return SessionDisplayData(
      bodyParts: bodyParts.toList(),
      exercises: exerciseMap.values.toList(),
      earliestTime: earliestTime,
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showExerciseDetailsDialog(BuildContext context, WidgetRef ref, ExerciseWithSets exercise) async {
    final db = ref.read(databaseProvider);
    final exerciseData = await db.getExerciseById(exercise.record.exerciseId);
    final bodyPart = exerciseData != null ? await db.getBodyPartById(exerciseData.bodyPartId) : null;
    
    if (exerciseData != null && context.mounted) {
      final exerciseRecordWithSession = ExerciseRecordWithSession(
        record: exercise.record,
        session: session,
        exercise: exerciseData,
        bodyPart: bodyPart,
        sets: exercise.sets,
      );
      
      showDialog(
        context: context,
        builder: (context) => TrainingDetailsDialog(
          exerciseRecord: exerciseRecordWithSession,
          isDark: isDark,
          l10n: l10n,
        ),
      );
    }
  }
}

// Widget for displaying a single exercise with its sets
class ExerciseItemWidget extends StatelessWidget {
  final ExerciseWithSets exercise;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback? onTap;

  const ExerciseItemWidget({
    super.key,
    required this.exercise,
    required this.isDark,
    required this.l10n,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.bodyPart,
              style: TextStyle(
                color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            if (exercise.name.isNotEmpty || exercise.sets.isNotEmpty) ...[
              const SizedBox(height: 6),
              if (exercise.name.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    exercise.name,
                    style: TextStyle(
                      color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (exercise.sets.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: exercise.sets.map((set) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${set.weight}kg x ${set.reps}',
                        style: TextStyle(
                          color: isDark ? AppTheme.primaryDark : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
