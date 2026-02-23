import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/appflowy_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../widgets/calendar/day_detail_card.dart';
import '../widgets/musclock_app_bar.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final sessionsAsync = ref.watch(sessionsProvider);

    // Get colors from theme or use fallback
    Color backgroundColor;
    Color textPrimary;
    Color textSecondary;
    Color textTertiary;
    Color accentColor = MusclockBrandColors.primary;

    try {
      backgroundColor = isDark
          ? const Color(0xFF23262B)
          : Colors.white;
      textPrimary = isDark
          ? Colors.white
          : Colors.black87;
      textSecondary = isDark
          ? Colors.white70
          : Colors.black54;
      textTertiary = isDark
          ? Colors.white38
          : Colors.black45;
    } catch (e) {
      backgroundColor = isDark
          ? const Color(0xFF1A1A1A)
          : Colors.white;
      textPrimary = isDark
          ? Colors.white
          : Colors.black87;
      textSecondary = isDark
          ? Colors.white70
          : Colors.black54;
      textTertiary = isDark
          ? Colors.white38
          : Colors.black45;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: MusclockAppBar(title: l10n.calendar),
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < 0) {
                // Swipe left - next month
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                });
              } else if (details.primaryVelocity! > 0) {
                // Swipe right - previous month
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                });
              }
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle: TextStyle(
                      color: textPrimary,
                    ),
                    weekendTextStyle: TextStyle(
                      color: textSecondary,
                    ),
                    todayDecoration: BoxDecoration(
                      border: Border.all(color: accentColor, width: 1),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(color: accentColor),
                    selectedDecoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    markerDecoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: textPrimary,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: textPrimary,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: textTertiary,
                    ),
                    weekendStyle: TextStyle(
                      color: textTertiary,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(context, day, accentColor: accentColor);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(context, day, isToday: true, accentColor: accentColor);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(context, day, isSelected: true, accentColor: accentColor);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Day Detail Card
              Expanded(
                child: sessionsAsync.when(
                  data: (sessions) {
                    if (_selectedDay == null) {
                      return const SizedBox.shrink();
                    }
                    final daySessions = sessions.where((s) {
                      return s.startTime.year == _selectedDay!.year &&
                          s.startTime.month == _selectedDay!.month &&
                          s.startTime.day == _selectedDay!.day;
                    }).toList();

                    return DayDetailCard(
                      date: _selectedDay!,
                      sessions: daySessions,
                      isDark: isDark,
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarDay(BuildContext context, DateTime day, {bool isToday = false, bool isSelected = false, Color accentColor = MusclockBrandColors.primary}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionsByDate = ref.watch(sessionsByDateProvider);

    // Normalize the day to date only (remove time)
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final daySessions = sessionsByDate[normalizedDay] ?? [];
    final hasWorkout = daySessions.isNotEmpty;

    // Get primary muscle group color
    Color? backgroundColor;
    if (hasWorkout && daySessions.isNotEmpty) {
      backgroundColor = accentColor.withOpacity(0.3);
    }

    Color textColor;
    if (isSelected) {
      textColor = isDark ? Colors.black : Colors.white;
    } else {
      textColor = isDark ? Colors.white : Colors.black87;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? accentColor
            : backgroundColor ?? Colors.transparent,
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(color: accentColor, width: 1)
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
