import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/appflowy_theme.dart';
import 'calendar_page.dart';
import 'today_page.dart';
import 'analysis_page.dart';
import 'plan_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CalendarPage(),
    TodayPage(),
    AnalysisPage(),
    PlanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      extendBody: true,
      bottomNavigationBar: _buildAppFlowyNavBar(context, l10n, isDark),
    );
  }

  Widget _buildAppFlowyNavBar(BuildContext context, AppLocalizations l10n, bool isDark) {
    // Get background color from AppFlowy theme or fallback
    Color backgroundColor;
    Color borderColor;

    backgroundColor = isDark
        ? const Color(0xFF23262B).withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);
    borderColor = isDark
        ? const Color(0xFF23262B).withValues(alpha: 0.5)
        : const Color(0x141F2329);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 3,
          sigmaY: 3,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: borderColor),
            ),
            color: backgroundColor,
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            elevation: 0,
            backgroundColor: Colors.transparent,
            indicatorColor: MusclockBrandColors.primary.withOpacity(0.2),
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.calendar_month_outlined,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                selectedIcon: Icon(
                  Icons.calendar_month,
                  color: MusclockBrandColors.primary,
                ),
                label: l10n.calendar,
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.fitness_center_outlined,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                selectedIcon: Icon(
                  Icons.fitness_center,
                  color: MusclockBrandColors.primary,
                ),
                label: l10n.today,
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.analytics_outlined,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                selectedIcon: Icon(
                  Icons.analytics,
                  color: MusclockBrandColors.primary,
                ),
                label: l10n.analysis,
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.event_note_outlined,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                selectedIcon: Icon(
                  Icons.event_note,
                  color: MusclockBrandColors.primary,
                ),
                label: l10n.plan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
