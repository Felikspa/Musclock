import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../providers/providers.dart';

/// Volume Statistics Tab
/// Displays total tonnage, weekly volume, and muscle distribution
class VolumeStatsTab extends ConsumerWidget {
  const VolumeStatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Total Tonnage Card
        _TotalTonnageCard(l10n: l10n),
        const SizedBox(height: 16),
        
        // Weekly Volume Chart Card
        _WeeklyVolumeCard(l10n: l10n),
        const SizedBox(height: 16),
        
        // Muscle Distribution Card
        _MuscleDistributionCard(l10n: l10n),
      ],
    );
  }
}

class _TotalTonnageCard extends ConsumerWidget {
  final AppLocalizations l10n;
  
  const _TotalTonnageCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalTonnageAsync = ref.watch(totalTonnageProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fitness_center),
                const SizedBox(width: 8),
                Text(
                  l10n.totalTonnage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            totalTonnageAsync.when(
              data: (tonnage) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Text(
                        _formatVolume(tonnage),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'kg',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
  
  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }
}

class _WeeklyVolumeCard extends ConsumerWidget {
  final AppLocalizations l10n;
  
  const _WeeklyVolumeCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyVolumeAsync = ref.watch(weeklyVolumeProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart),
                const SizedBox(width: 8),
                Text(
                  l10n.weeklyVolume,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            weeklyVolumeAsync.when(
              data: (volumes) {
                if (volumes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(l10n.noData),
                    ),
                  );
                }
                
                // Find max for scaling
                final maxVolume = volumes.map((v) => v.volume).reduce((a, b) => a > b ? a : b);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: volumes.map((week) {
                      final heightRatio = maxVolume > 0 ? week.volume / maxVolume : 0.0;
                      return Column(
                        children: [
                          Text(
                            _formatVolume(week.volume),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 40,
                            height: (heightRatio * 100).clamp(10.0, 100.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'W${week.weekNumber}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
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
  
  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }
}

class _MuscleDistributionCard extends ConsumerWidget {
  final AppLocalizations l10n;
  
  const _MuscleDistributionCard({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muscleVolumeAsync = ref.watch(muscleVolumeDistributionProvider);
    
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
                  l10n.muscleDistribution,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            muscleVolumeAsync.when(
              data: (distribution) {
                if (distribution.isEmpty || distribution.values.every((v) => v == 0)) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(l10n.noData),
                    ),
                  );
                }
                
                // Sort by volume
                final sortedEntries = distribution.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                
                // Find max for percentage calculation
                final totalVolume = distribution.values.fold(0.0, (a, b) => a + b);
                
                return Column(
                  children: sortedEntries.take(6).map((entry) {
                    final percentage = totalVolume > 0 ? (entry.value / totalVolume * 100) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '${percentage.toStringAsFixed(0)}%',
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.bodySmall,
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
