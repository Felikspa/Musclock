import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database/database.dart';
import '../../providers/providers.dart';
import '../../providers/workout_session_provider.dart';
import '../../widgets/muscle_group_helper.dart';
import '../../widgets/add_exercise_sheet.dart';
import '../../widgets/select_datetime_sheet.dart';
import 'exercise_records_list.dart';

class DayDetailCard extends ConsumerWidget {
  final DateTime date;
  final List<WorkoutSession> sessions;
  final bool isDark;

  const DayDetailCard({
    super.key,
    required this.date,
    required this.sessions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(date, now);
    final dayFormat = DateFormat('EEEE, MMM d');

    // Check if date is within 90 days and is not today
    final daysDiff = now.difference(date).inDays;
    final canAddWorkout = !isToday && daysDiff <= 90;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: isToday ? Border.all(color: AppTheme.accent, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? l10n.today : dayFormat.format(date),
                    style: TextStyle(
                      color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (sessions.isNotEmpty)
                    _buildMuscleGroupsText(context, ref),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isToday && sessions.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        l10n.rest,
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (canAddWorkout)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                      ),
                      onSelected: (value) {
                        if (value == 'add_workout') {
                          _showAddWorkoutFlow(context, ref, l10n);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'add_workout',
                          child: Row(
                            children: [
                              const Icon(Icons.add, size: 20),
                              const SizedBox(width: 8),
                              Text(l10n.addWorkout),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sessions.isNotEmpty)
            Expanded(
              child: ExerciseRecordsList(
                sessions: sessions,
                isDark: isDark,
                l10n: l10n,
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  l10n.noSessions,
                  style: TextStyle(
                    color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupsText(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    
    return FutureBuilder<List<String>>(
      future: _getMuscleGroupsForSessions(ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Localize muscle group names
        final localizedNames = snapshot.data!.map((name) {
          final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(name);
          return muscleGroup.getLocalizedName(locale);
        }).toList();
        
        return Text(
          localizedNames.join(' + '),
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 12,
          ),
        );
      },
    );
  }

  Future<List<String>> _getMuscleGroupsForSessions(WidgetRef ref) async {
    final repo = ref.read(sessionRepositoryProvider);
    final muscleNames = <String>[];
    
    if (sessions.isEmpty) return muscleNames;
    
    // Use optimized JOIN query to get all exercise records with details
    final sessionIds = sessions.map((s) => s.id).toList();
    final recordsBySession = await repo.getMultipleSessionsExerciseRecordsWithDetails(sessionIds);
    
    // Collect unique body part names
    for (final sessionId in sessionIds) {
      final records = recordsBySession[sessionId] ?? [];
      for (final record in records) {
        if (!muscleNames.contains(record.bodyPart.name)) {
          muscleNames.add(record.bodyPart.name);
        }
      }
    }
    
    return muscleNames;
  }

  void _showAddWorkoutFlow(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    // First, show the date/time picker
    final now = DateTime.now();
    final minDate = now.subtract(const Duration(days: 90));

    // Initialize with the selected date and default time (noon)
    final initialDate = DateTime(date.year, date.month, date.day, 12, 0);

    final selectedDateTime = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectDateTimeSheet(
        initialDate: initialDate,
        minDate: minDate,
        maxDate: now,
      ),
    );

    if (selectedDateTime == null || !context.mounted) return;

    // Start a new session with the selected time
    await ref.read(workoutSessionProvider.notifier).startSessionWithTime(selectedDateTime);

    if (context.mounted) {
      // Then show the add exercise sheet
      _showAddExerciseSheet(context, l10n);
    }
  }

  void _showAddExerciseSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => AddExerciseSheet(
          scrollController: scrollController,
          l10n: l10n,
        ),
      ),
    );
  }
}
