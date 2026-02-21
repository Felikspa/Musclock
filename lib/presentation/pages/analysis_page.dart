import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../data/database/database.dart';
import '../../domain/repositories/session_repository.dart';
import '../providers/providers.dart';

class AnalysisPage extends ConsumerWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.analysis),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.statistics),
              Tab(text: l10n.heatmap),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _StatisticsTab(l10n: l10n),
            _HeatmapTab(l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _StatisticsTab extends ConsumerWidget {
  final AppLocalizations l10n;

  const _StatisticsTab({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyPartsAsync = ref.watch(bodyPartsProvider);
    final sessionsAsync = ref.watch(sessionsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Global Stats
        _GlobalStatsCard(sessionsAsync: sessionsAsync, l10n: l10n),
        const SizedBox(height: 24),
        // Body Parts Stats
        Text(
          l10n.bodyPart,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        bodyPartsAsync.when(
          data: (bodyParts) {
            if (bodyParts.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      l10n.noData,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: bodyParts.map((bp) {
                return _BodyPartStatCard(
                  bodyPart: bp,
                  l10n: l10n,
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Error: $e'),
        ),
      ],
    );
  }
}

class _GlobalStatsCard extends StatelessWidget {
  final AsyncValue<List<WorkoutSession>> sessionsAsync;
  final AppLocalizations l10n;

  const _GlobalStatsCard({required this.sessionsAsync, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics),
                const SizedBox(width: 8),
                Text(
                  l10n.statistics,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return Center(child: Text(l10n.noData));
                }

                final now = DateTime.now().toUtc();
                final firstSession = sessions.last;
                final totalDays = now.difference(firstSession.startTime).inDays + 1;
                final avgPerWeek = totalDays > 0 ? (sessions.length / totalDays * 7).toStringAsFixed(1) : '0';

                return Column(
                  children: [
                    _StatRow(
                      icon: Icons.fitness_center,
                      label: l10n.totalSessions,
                      value: '${sessions.length}',
                    ),
                    _StatRow(
                      icon: Icons.calendar_today,
                      label: l10n.totalDays,
                      value: '$totalDays',
                    ),
                    _StatRow(
                      icon: Icons.trending_up,
                      label: l10n.avgPerWeek,
                      value: avgPerWeek,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _BodyPartStatCard extends ConsumerWidget {
  final BodyPart bodyPart;
  final AppLocalizations l10n;

  const _BodyPartStatCard({required this.bodyPart, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);
    final calculateRestDays = ref.watch(calculateRestDaysProvider);
    final calculateFrequency = ref.watch(calculateFrequencyProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bodyPart.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            sessionsAsync.when(
              data: (sessions) {
                // Get sessions containing this body part
                final repo = ref.read(sessionRepositoryProvider);
                return FutureBuilder(
                  future: repo.getSessionsByBodyPart(bodyPart.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final bpSessions = snapshot.data!;
                    if (bpSessions.isEmpty) {
                      return Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(l10n.noData),
                        ],
                      );
                    }

                    final now = DateTime.now().toUtc();
                    final lastSession = bpSessions.first;
                    final totalHours = now.difference(lastSession.startTime).inHours;
                    final restDays = totalHours ~/ 24;
                    final restHours = totalHours % 24;
                    final restTimeText = '$restDays ${l10n.days} $restHours ${l10n.hours}';

                    return Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.timer,
                            label: l10n.currentRest,
                            value: restTimeText,
                          ),
                        ),
                        Expanded(
                          child: _MiniStat(
                            icon: Icons.repeat,
                            label: l10n.frequency,
                            value: '${bpSessions.length}x',
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _HeatmapTab extends ConsumerWidget {
  final AppLocalizations l10n;

  const _HeatmapTab({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.grid_view),
                    const SizedBox(width: 8),
                    Text(
                      l10n.heatmap,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const Divider(),
                sessionsAsync.when(
                  data: (sessions) {
                    if (sessions.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(l10n.noData),
                        ),
                      );
                    }
                    return _HeatmapGrid(sessions: sessions);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error: $e'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final List<WorkoutSession> sessions;

  const _HeatmapGrid({required this.sessions});

  @override
  Widget build(BuildContext context) {
    // Group sessions by date
    final Map<String, int> sessionCountByDate = {};
    for (final session in sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      sessionCountByDate[key] = (sessionCountByDate[key] ?? 0) + 1;
    }

    // Get last 12 weeks
    final now = DateTime.now();
    final List<Widget> rows = [];

    // Week headers
    final weekHeaders = ['Mon', '', 'Wed', '', 'Fri', '', 'Sun'];
    rows.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: weekHeaders.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );

    // Generate weeks
    for (var week = 11; week >= 0; week--) {
      final List<Widget> weekCells = [];
      for (var day = 1; day <= 7; day++) {
        final date = now.subtract(Duration(days: week * 7 + (7 - day)));
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final count = sessionCountByDate[key] ?? 0;

        Color bgColor;
        if (count == 0) {
          bgColor = Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3);
        } else if (count == 1) {
          bgColor = Theme.of(context).colorScheme.primaryContainer;
        } else if (count == 2) {
          bgColor = Theme.of(context).colorScheme.primary;
        } else {
          bgColor = Theme.of(context).colorScheme.primary;
        }

        weekCells.add(
          Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(2),
            ),
            height: 16,
          ),
        );
      }

      rows.add(
        Row(children: weekCells),
      );
    }

    return Column(children: rows);
  }
}
