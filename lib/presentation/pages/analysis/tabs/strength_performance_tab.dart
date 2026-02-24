import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../providers/providers.dart';

/// Strength Performance Tab
/// Displays personal records, e1RM, and relative strength
class StrengthPerformanceTab extends ConsumerWidget {
  const StrengthPerformanceTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Personal Records Card
        _PersonalRecordsCard(l10n: l10n),
        const SizedBox(height: 16),
        
        // Top Exercises e1RM Card
        _TopExercisesE1RMCard(l10n: l10n),
      ],
    );
  }
}

class _PersonalRecordsCard extends ConsumerWidget {
  final AppLocalizations l10n;
  
  const _PersonalRecordsCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prAsync = ref.watch(personalRecordsProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events),
                const SizedBox(width: 8),
                Text(
                  l10n.personalRecords,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            prAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(l10n.noData),
                    ),
                  );
                }
                
                return Column(
                  children: records.take(5).map((pr) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pr.exerciseName,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  l10n.weightPR,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${pr.maxWeight?.toStringAsFixed(1) ?? "-"} kg',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              if (pr.maxE1RM != null)
                                Text(
                                  'e1RM: ${pr.maxE1RM!.toStringAsFixed(1)} kg',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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

class _TopExercisesE1RMCard extends ConsumerWidget {
  final AppLocalizations l10n;
  
  const _TopExercisesE1RMCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prAsync = ref.watch(personalRecordsProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up),
                const SizedBox(width: 8),
                Text(
                  l10n.e1RMGrowth,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            prAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(l10n.noData),
                    ),
                  );
                }
                
                // Get top 5 exercises by e1RM
                final topRecords = records.take(5).toList();
                
                return Column(
                  children: topRecords.map((pr) {
                    // Calculate relative strength if we have body weight
                    final bodyMetricsAsync = ref.watch(bodyMetricsProvider);
                    double? relativeStrength;
                    
                    bodyMetricsAsync.whenData((metrics) {
                      if (metrics != null && metrics.weight != null && pr.maxE1RM != null) {
                        relativeStrength = pr.maxE1RM! / metrics.weight!;
                      }
                    });
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pr.exerciseName,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${l10n.estimated1RM}: ${pr.maxE1RM?.toStringAsFixed(1) ?? "-"} kg',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (relativeStrength != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${relativeStrength!.toStringAsFixed(2)} ${l10n.perKg}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
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
