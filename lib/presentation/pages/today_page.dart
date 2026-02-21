import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../data/database/database.dart';
import '../providers/providers.dart';
import '../providers/workout_session_provider.dart';
import '../widgets/today_session_view.dart';
import '../widgets/active_workout_view.dart';
import '../widgets/add_exercise_sheet.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sessionState = ref.watch(workoutSessionProvider);
    final bodyPartsAsync = ref.watch(bodyPartsProvider);
    final sessionsAsync = ref.watch(sessionsProvider);

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
          ? const ActiveWorkoutView()
          : todaySessions.isNotEmpty
              ? TodaySessionView(sessions: todaySessions)
              : _NoWorkoutView(bodyPartsAsync: bodyPartsAsync, l10n: l10n),
      floatingActionButton: sessionState.isActive
          ? null  // No FAB when session is active - auto-save on add
          : FloatingActionButton.extended(
              onPressed: () async {
                // Start session and show add exercise dialog
                await ref.read(workoutSessionProvider.notifier).startNewSession();
                if (context.mounted) {
                  _showAddExerciseSheet(context, ref, l10n);
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
        builder: (context, scrollController) => AddExerciseSheet(
          scrollController: scrollController,
          l10n: l10n,
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
