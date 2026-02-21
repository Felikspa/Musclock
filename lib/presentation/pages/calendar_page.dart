import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/calendar/day_detail_card.dart';

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
    final sessionsAsync = ref.watch(sessionsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Muscle Clock',
                  style: TextStyle(
                    color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
              ),
              
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
                      color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                    ),
                    weekendTextStyle: TextStyle(
                      color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                    ),
                    todayDecoration: BoxDecoration(
                      border: Border.all(color: AppTheme.accent, width: 1),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(color: AppTheme.accent),
                    selectedDecoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                    ),
                    weekendStyle: TextStyle(
                      color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(context, day);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(context, day, isToday: true);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(context, day, isSelected: true);
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

  Widget _buildCalendarDay(BuildContext context, DateTime day, {bool isToday = false, bool isSelected = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionsByDate = ref.watch(sessionsByDateProvider);
    
    // Normalize the day to date only (remove time)
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final daySessions = sessionsByDate[normalizedDay] ?? [];
    final hasWorkout = daySessions.isNotEmpty;
    
    // Get primary muscle group color
    Color? backgroundColor;
    if (hasWorkout && daySessions.isNotEmpty) {
      backgroundColor = AppTheme.accent.withOpacity(0.3);
    }
    
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppTheme.accent 
            : backgroundColor ?? Colors.transparent,
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(color: AppTheme.accent, width: 1)
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isSelected 
                ? AppTheme.primaryDark 
                : isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

