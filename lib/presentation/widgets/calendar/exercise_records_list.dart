import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database/database.dart';
import '../../../domain/entities/exercise_record_with_session.dart';
import '../../../domain/repositories/session_repository.dart';
import '../../providers/providers.dart';
import 'exercise_record_card.dart';

class ExerciseRecordsList extends ConsumerWidget {
  final List<WorkoutSession> sessions;
  final bool isDark;
  final AppLocalizations l10n;

  const ExerciseRecordsList({
    super.key,
    required this.sessions,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(sessionRepositoryProvider);

    return FutureBuilder<List<ExerciseRecordWithSession>>(
      future: _getAllExerciseRecords(repo),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final exerciseRecords = snapshot.data!;
        
        if (exerciseRecords.isEmpty) {
          return Center(
            child: Text(
              l10n.noData,
              style: TextStyle(
                color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
              ),
            ),
          );
        }

        // Group by exercise for display
        return ListView.builder(
          itemCount: exerciseRecords.length,
          itemBuilder: (context, index) {
            return ExerciseRecordCard(
              exerciseRecord: exerciseRecords[index],
              isDark: isDark,
              l10n: l10n,
            );
          },
        );
      },
    );
  }

  Future<List<ExerciseRecordWithSession>> _getAllExerciseRecords(SessionRepository repo) async {
    if (sessions.isEmpty) return [];
    
    // Get all session IDs
    final sessionIds = sessions.map((s) => s.id).toList();
    
    // Use optimized JOIN query to get all exercise records with details
    final Map<String, List<ExerciseRecordWithDetails>> recordsBySession = 
        await repo.getMultipleSessionsExerciseRecordsWithDetails(sessionIds);
    
    // Collect all exercise record IDs for batch set query
    final List<String> allRecordIds = [];
    for (final sessionId in sessionIds) {
      final records = recordsBySession[sessionId] ?? [];
      for (final record in records) {
        allRecordIds.add(record.record.id);
      }
    }
    
    // Batch query all sets at once
    final Map<String, List<SetRecord>> setsByRecordId = 
        await repo.getSetsByExerciseRecordIds(allRecordIds);
    
    // Build the result list
    final List<ExerciseRecordWithSession> allRecords = [];
    
    for (final session in sessions) {
      final detailsList = recordsBySession[session.id] ?? [];
      
      for (final details in detailsList) {
        final sets = setsByRecordId[details.record.id] ?? [];
        allRecords.add(ExerciseRecordWithSession(
          record: details.record,
          session: session,
          exercise: details.exercise,
          bodyPart: details.bodyPart,
          sets: sets,
        ));
      }
    }

    // Sort by session start time
    allRecords.sort((a, b) => a.session.startTime.compareTo(b.session.startTime));
    
    return allRecords;
  }
}
