import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'calendar_page.dart';
import 'today_page.dart';
import 'analysis_page.dart';
import 'plan_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CalendarPage(),
    TodayPage(),
    AnalysisPage(),
    PlanPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_month),
            label: l10n.calendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center),
            label: l10n.today,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics),
            label: l10n.analysis,
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_note),
            label: l10n.plan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
