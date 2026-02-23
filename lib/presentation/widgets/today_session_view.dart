import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/database/database.dart';
import '../../domain/entities/exercise_record_with_session.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import 'muscle_group_helper.dart';
import 'exercise_helper.dart';
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
  final List<String> bodyParts;  // All body parts associated with this exercise
  final List<SetRecord> sets;
  final ExerciseRecord record;

  ExerciseWithSets({
    required this.name,
    required this.bodyParts,
    required this.sets,
    required this.record,
  });
}

// Provider for watching records by session (real-time updates)
final _recordsProvider = StreamProvider.family<List<ExerciseRecord>, String>((ref, sessionId) {
  final db = ref.watch(databaseProvider);
  return db.watchRecordsBySession(sessionId);
});

// Display today's saved training sessions
class TodaySessionView extends ConsumerWidget {
  final List<WorkoutSession> sessions;
  final void Function(WorkoutSession session)? onSessionTap;

  const TodaySessionView({
    super.key, 
    required this.sessions,
    this.onSessionTap,
  });

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
            onTap: onSessionTap != null ? () => onSessionTap!(session) : null,
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
  final VoidCallback? onTap;

  const SavedSessionCard({
    super.key,
    required this.session,
    required this.sessionIndex,
    required this.isDark,
    required this.l10n,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(_recordsProvider(session.id));

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ExerciseRecord> records, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    
    return FutureBuilder<SessionDisplayData>(
      future: _getSessionDisplayData(records, ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final data = snapshot.data!;
        
        final earliestTime = data.earliestTime ?? session.startTime;
        
        // Localize body parts
        final localizedBodyParts = data.bodyParts.map((bp) {
          final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bp);
          return muscleGroup?.getLocalizedName(locale) ?? bp;
        }).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    localizedBodyParts.join(' + '),
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
              locale: locale,
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
      // Check if this is a body-part-only record (exerciseId starts with "bodyPart:")
      if (record.exerciseId != null && record.exerciseId!.startsWith('bodyPart:')) {
        // Extract body part ID from "bodyPart:xxx"
        final bodyPartId = record.exerciseId!.substring('bodyPart:'.length);
        final bodyPart = await db.getBodyPartById(bodyPartId);
        if (bodyPart != null) {
          bodyParts.add(bodyPart.name);
          
          // Create a body-part-only entry
          final key = 'bodyPart:${bodyPart.id}';
          if (!exerciseMap.containsKey(key)) {
            exerciseMap[key] = ExerciseWithSets(
              name: '',  // No specific exercise name
              bodyParts: [bodyPart.name],
              sets: [],  // No sets for body-part-only entry
              record: record,
            );
          }
          
          if (earliestTime == null || session.startTime.isBefore(earliestTime)) {
            earliestTime = session.startTime;
          }
        }
        continue;
      }
      
      // Normal exercise record
      final exercise = await db.getExerciseById(record.exerciseId!);
      if (exercise != null) {
        // Parse bodyPartIds to get all body parts
        final bodyPartIds = _parseBodyPartIds(exercise.bodyPartIds);
        
        // Get all body parts associated with this exercise
        final List<String> bodyPartNames = [];
        for (final bpId in bodyPartIds) {
          final bp = await db.getBodyPartById(bpId);
          if (bp != null) {
            bodyPartNames.add(bp.name);
            bodyParts.add(bp.name);
          }
        }
        
        final sets = await db.getSetsByExerciseRecord(record.id);
        
        if (exerciseMap.containsKey(exercise.id)) {
          exerciseMap[exercise.id]!.sets.addAll(sets);
        } else {
          exerciseMap[exercise.id] = ExerciseWithSets(
            name: exercise.name,
            bodyParts: bodyPartNames,
            sets: sets,
            record: record,
          );
        }
        
        if (earliestTime == null || session.startTime.isBefore(earliestTime)) {
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

  /// Parse bodyPartIds JSON array string to List<String>
  List<String> _parseBodyPartIds(String? bodyPartIdsJson) {
    // Handle NULL or empty values
    if (bodyPartIdsJson == null || bodyPartIdsJson.isEmpty || bodyPartIdsJson == '[]') return [];
    try {
      final decoded = jsonDecode(bodyPartIdsJson);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  String _formatTime(DateTime time) {
    // 使用工具类将 UTC 时间转换为本地时间后格式化
    return DateTimeUtils.formatTime(time);
  }

  void _showExerciseDetailsDialog(BuildContext context, WidgetRef ref, ExerciseWithSets exercise) async {
    final db = ref.read(databaseProvider);
    final exerciseId = exercise.record.exerciseId;
    final exerciseData = exerciseId != null ? await db.getExerciseById(exerciseId) : null;
    // Parse bodyPartIds to get all body parts
    BodyPart? bodyPart;
    List<BodyPart> bodyPartsList = [];
    if (exerciseData != null) {
      final bodyPartIds = _parseBodyPartIds(exerciseData.bodyPartIds);
      final primaryBodyPartId = bodyPartIds.isNotEmpty ? bodyPartIds.first : null;
      bodyPart = primaryBodyPartId != null ? await db.getBodyPartById(primaryBodyPartId) : null;
      
      // Get all body parts
      for (final bpId in bodyPartIds) {
        final bp = await db.getBodyPartById(bpId);
        if (bp != null) {
          bodyPartsList.add(bp);
        }
      }
    }
    
    if (exerciseData != null && context.mounted) {
      final exerciseRecordWithSession = ExerciseRecordWithSession(
        record: exercise.record,
        session: session,
        exercise: exerciseData,
        bodyPart: bodyPart,
        bodyParts: bodyPartsList,
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
  final String locale;
  final VoidCallback? onTap;

  const ExerciseItemWidget({
    super.key,
    required this.exercise,
    required this.isDark,
    required this.l10n,
    required this.locale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get localized names
    final displayExerciseName = ExerciseHelper.getLocalizedName(exercise.name, locale);
    
    // Build body part colored boxes
    final List<Widget> bodyPartWidgets = [];
    for (final bpName in exercise.bodyParts) {
      final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bpName);
      final displayName = muscleGroup?.getLocalizedName(locale) ?? bpName;
      final color = muscleGroup != null 
          ? AppTheme.getMuscleColor(muscleGroup) 
          : MuscleGroupHelper.getColorForBodyPart(bpName);
      bodyPartWidgets.add(
        Container(
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
        ),
      );
    }
    
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
            // Display all body parts as colored boxes
            if (bodyPartWidgets.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: bodyPartWidgets,
              ),
            
            if (exercise.name.isNotEmpty || exercise.sets.isNotEmpty) ...[
              const SizedBox(height: 6),
              if (exercise.name.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    displayExerciseName,
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
