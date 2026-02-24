import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../data/database/database.dart';
import '../../core/theme/appflowy_theme.dart';
import '../../core/utils/date_time_utils.dart';
import '../providers/providers.dart';
import '../widgets/musclock_app_bar.dart';
import '../widgets/muscle_group_helper.dart';
import '../widgets/calendar/heatmap_bar_chart.dart';

class AnalysisPage extends ConsumerWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: MusclockAppBar(title: l10n.analysis),
        body: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                labelColor: MusclockBrandColors.primary,
                unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.black54,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: MusclockBrandColors.primary,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: l10n.statistics),
                  Tab(text: l10n.heatmap),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _StatisticsTab(l10n: l10n),
                  _HeatmapTab(l10n: l10n),
                ],
              ),
            ),
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
        const SizedBox(height: 16),
        // Body Parts Stats
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
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.1,
              ),
              itemCount: bodyParts.length,
              itemBuilder: (context, index) {
                return _BodyPartStatCard(
                  bodyPart: bodyParts[index],
                  l10n: l10n,
                );
              },
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

                final now = DateTimeUtils.nowUtc;
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
    final locale = Localizations.localeOf(context).languageCode;
    
    // Get localized body part name
    final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bodyPart.name);
    final displayBodyPartName = muscleGroup?.getLocalizedName(locale) ?? bodyPart.name;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayBodyPartName,
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

                    final now = DateTimeUtils.nowUtc;
                    final lastSession = bpSessions.first;
                    final totalHours = now.difference(lastSession.startTime).inHours;
                    final restDays = totalHours ~/ 24;
                    final restHours = totalHours % 24;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: l10n.currentRest,
                            value: '$restDays ${l10n.daysAbbr}',
                            subValue: '$restHours ${l10n.hoursAbbr}',
                          ),
                        ),
                        Expanded(
                          child: _MiniStat(
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
  final String label;
  final String value;
  final String? subValue; // for showing hours below days

  const _MiniStat({
    required this.label,
    required this.value,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (subValue != null) ...[
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            subValue!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ] else
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
    final currentRange = ref.watch(heatmapTimeRangeProvider);
    final days = currentRange == HeatmapTimeRange.last7Days ? 7 : 30;
    final tpAsync = ref.watch(trainingPointsInRangeProvider(currentRange));
    final maxTP = ref.watch(maxTrainingPointsInRangeProvider(currentRange));
    final locale = Localizations.localeOf(context).languageCode;

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
                
                // SegmentedButton for time range selection
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SegmentedButton<HeatmapTimeRange>(
                    segments: [
                      ButtonSegment<HeatmapTimeRange>(
                        value: HeatmapTimeRange.last7Days,
                        label: Text(l10n.last7Days),
                      ),
                      ButtonSegment<HeatmapTimeRange>(
                        value: HeatmapTimeRange.last30Days,
                        label: Text(l10n.last30Days),
                      ),
                    ],
                    selected: {currentRange},
                    onSelectionChanged: (Set<HeatmapTimeRange> selected) {
                      ref.read(heatmapTimeRangeProvider.notifier).state = selected.first;
                    },
                  ),
                ),
                
                // Heatmap bar chart
                tpAsync.when(
                  data: (tpMap) {
                    if (tpMap.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(l10n.noData),
                        ),
                      );
                    }
                    return HeatmapBarChart(
                      trainingPoints: tpMap,
                      maxTP: maxTP,
                      days: days,
                      locale: locale,
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, s) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Error: $e'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
