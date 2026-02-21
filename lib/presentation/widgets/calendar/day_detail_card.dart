import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database/database.dart';
import '../../providers/providers.dart';
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
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final dayFormat = DateFormat('EEEE, MMM d');
    
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
              if (isToday && sessions.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.2),
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
    return FutureBuilder<List<String>>(
      future: _getMuscleGroupsForSessions(ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        return Text(
          snapshot.data!.join(' + '),
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
}
