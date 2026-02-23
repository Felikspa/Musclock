import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/database/database.dart';
import '../../../domain/entities/exercise_record_with_session.dart';
import '../muscle_group_helper.dart';
import '../exercise_helper.dart';
import '../training_details_dialog.dart';

class ExerciseRecordCard extends StatelessWidget {
  final ExerciseRecordWithSession exerciseRecord;
  final bool isDark;
  final AppLocalizations l10n;

  const ExerciseRecordCard({
    super.key,
    required this.exerciseRecord,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final exercise = exerciseRecord;
    final locale = Localizations.localeOf(context).languageCode;

    // Get localized exercise name
    final rawExerciseName = exercise.exercise?.name;
    final exerciseName = rawExerciseName != null 
        ? ExerciseHelper.getLocalizedName(rawExerciseName, locale)
        : null;

    // Get all body parts for display
    final bodyPartsList = exercise.bodyParts.isNotEmpty 
        ? exercise.bodyParts 
        : (exercise.bodyPart != null ? [exercise.bodyPart!] : <BodyPart>[]);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // Show details dialog instead of expanding
          showDialog(
            context: context,
            builder: (context) => TrainingDetailsDialog(
              exerciseRecord: exerciseRecord,
              isDark: isDark,
              l10n: l10n,
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Body parts color chips - display all
              if (bodyPartsList.isNotEmpty)
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: bodyPartsList.map((bp) {
                      final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bp.name);
                      final color = muscleGroup != null 
                          ? AppTheme.getMuscleColor(muscleGroup) 
                          : MuscleGroupHelper.getColorForBodyPart(bp.name);
                      final displayName = muscleGroup?.getLocalizedName(locale) ?? bp.name;
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
                    }).toList(),
                  ),
                )
              else
                const SizedBox.shrink(),
              const SizedBox(width: 8),
              // Exercise name and sets info
              Expanded(
                child: exerciseName != null
                    ? (exercise.sets.isNotEmpty
                        ? Text(
                            '$exerciseName • ${exercise.sets.length} sets',
                            style: TextStyle(
                              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            exerciseName,
                            style: TextStyle(
                              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ))
                    : (bodyPartsList.isNotEmpty
                        ? Text(
                            bodyPartsList.first.name,
                            style: TextStyle(
                              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox.shrink()),
              ),
              const SizedBox(width: 8),
              // Time on the right
              Text(
                // 使用工具类将 UTC 时间转换为本地时间后格式化
                DateTimeUtils.formatTime(exercise.session.startTime),
                style: TextStyle(
                  color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
