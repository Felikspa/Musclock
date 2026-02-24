import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/appflowy_theme.dart';
import '../../widgets/analysis/body_metrics_card.dart';
import 'tabs/volume_stats_tab.dart';
import 'tabs/strength_performance_tab.dart';
import 'tabs/exercise_analysis_tab.dart';

/// Training Analysis Detail Page
/// Comprehensive statistics and analysis for training data
class TrainingAnalysisDetailPage extends ConsumerStatefulWidget {
  const TrainingAnalysisDetailPage({super.key});

  @override
  ConsumerState<TrainingAnalysisDetailPage> createState() => _TrainingAnalysisDetailPageState();
}

class _TrainingAnalysisDetailPageState extends ConsumerState<TrainingAnalysisDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.detail),
        automaticallyImplyLeading: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: MusclockBrandColors.primary,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
          indicatorColor: MusclockBrandColors.primary,
          tabs: [
            Tab(text: l10n.bodyMetrics),
            Tab(text: l10n.volumeStats),
            Tab(text: l10n.strengthPerformance),
            Tab(text: l10n.exerciseAnalysis),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Padding(
            padding: EdgeInsets.all(16),
            child: BodyMetricsCard(),
          ),
          VolumeStatsTab(),
          StrengthPerformanceTab(),
          ExerciseAnalysisTab(),
        ],
      ),
    );
  }
}
