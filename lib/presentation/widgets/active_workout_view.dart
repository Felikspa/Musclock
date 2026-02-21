import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../providers/workout_session_provider.dart';
import '../widgets/exercise_card.dart';
import 'add_exercise_sheet.dart';

class ActiveWorkoutView extends ConsumerStatefulWidget {
  final WorkoutSessionState sessionState;

  const ActiveWorkoutView({super.key, required this.sessionState});

  @override
  ConsumerState<ActiveWorkoutView> createState() => _ActiveWorkoutViewState();
}

class _ActiveWorkoutViewState extends ConsumerState<ActiveWorkoutView> {
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
            return ExerciseCard(
              exerciseInSession: exerciseInSession,
              exerciseIndex: index,
            );
          }),

        const SizedBox(height: 16),

        // Add Exercise Button
        OutlinedButton.icon(
          onPressed: () => _showAddExerciseSheet(context, ref, l10n),
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
          autoCloseOnAdd: true,
        ),
      ),
    );
  }
}
