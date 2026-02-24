import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../providers/providers.dart';

/// Exercise Analysis Tab
/// Displays exercise preference and distribution
class ExerciseAnalysisTab extends ConsumerWidget {
  const ExerciseAnalysisTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Exercise Preference Card
        _ExercisePreferenceCard(l10n: l10n),
      ],
    );
  }
}

class _ExercisePreferenceCard extends ConsumerWidget {
  final AppLocalizations l10n;
  
  const _ExercisePreferenceCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenceAsync = ref.watch(exercisePreferenceProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart),
                const SizedBox(width: 8),
                Text(
                  l10n.exercisePreference,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            preferenceAsync.when(
              data: (preferences) {
                if (preferences.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(l10n.noData),
                    ),
                  );
                }
                
                // Calculate total sessions for percentage
                final totalSessions = preferences.fold<int>(
                  0, (sum, p) => sum + p.sessionCount
                );
                
                // Get top 6 exercises
                final topExercises = preferences.take(6).toList();
                
                // Colors for pie chart simulation
                final colors = [
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.red,
                  Colors.teal,
                ];
                
                return Column(
                  children: [
                    // Visual bar representation
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 24,
                        child: Row(
                          children: topExercises.asMap().entries.map((entry) {
                            final index = entry.key;
                            final pref = entry.value;
                            final percentage = totalSessions > 0 
                                ? pref.sessionCount / totalSessions 
                                : 0.0;
                            
                            return Expanded(
                              flex: (percentage * 100).round().clamp(1, 100),
                              child: Container(
                                color: colors[index % colors.length],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Legend
                    ...topExercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final pref = entry.value;
                      final percentage = totalSessions > 0 
                          ? pref.sessionCount / totalSessions * 100 
                          : 0.0;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pref.exerciseName,
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${pref.sessionCount}x',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 45,
                              child: Text(
                                '${percentage.toStringAsFixed(0)}%',
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, s) => Center(
                child: Text('${l10n.error}: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
