import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/database.dart';
import '../../domain/entities/exercise_record_with_session.dart';
import '../../domain/repositories/session_repository.dart';
import '../providers/providers.dart';
import '../widgets/calendar/exercise_record_card.dart';

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
                    
                    return _DayDetailCard(
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
    final sessionsAsync = ref.watch(sessionsProvider);
    
    return sessionsAsync.when(
      data: (sessions) {
        final daySessions = sessions.where((s) {
          return s.startTime.year == day.year &&
              s.startTime.month == day.month &&
              s.startTime.day == day.day;
        }).toList();
        
        final hasWorkout = daySessions.isNotEmpty;
        
        // Get primary muscle group color
        Color? backgroundColor;
        if (hasWorkout && daySessions.isNotEmpty) {
          // Get exercises for this session to find muscle groups
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
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _DayDetailCard extends ConsumerWidget {
  final DateTime date;
  final List<WorkoutSession> sessions;
  final bool isDark;

  const _DayDetailCard({
    required this.date,
    required this.sessions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final dayFormat = DateFormat('EEEE, MMM d');
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: isToday ? Border.all(color: AppTheme.accent, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday ? l10n.today : dayFormat.format(date),
                    style: TextStyle(
                      color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (sessions.isNotEmpty)
                    _buildMuscleGroupsText(context, ref),
                ],
              ),
              if (isToday && sessions.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    l10n.rest,
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (sessions.isNotEmpty)
            Expanded(
              child: _ExerciseRecordsList(
                sessions: sessions,
                isDark: isDark,
                l10n: l10n,
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  l10n.noSessions,
                  style: TextStyle(
                    color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupsText(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<String>>(
      future: _getMuscleGroupsForSessions(ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        return Text(
          snapshot.data!.join(' + '),
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 12,
          ),
        );
      },
    );
  }

  Future<List<String>> _getMuscleGroupsForSessions(WidgetRef ref) async {
    final repo = ref.read(sessionRepositoryProvider);
    final muscleNames = <String>[];
    
    for (final session in sessions) {
      final records = await repo.getRecordsBySession(session.id);
      for (final record in records) {
        final exercise = await repo.getExerciseById(record.exerciseId);
        if (exercise != null) {
          final bodyPart = await repo.getBodyPartById(exercise.bodyPartId);
          if (bodyPart != null && !muscleNames.contains(bodyPart.name)) {
            muscleNames.add(bodyPart.name);
          }
        }
      }
    }
    return muscleNames;
  }
}

// Display all exercise records from all sessions for a day
class _ExerciseRecordsList extends ConsumerWidget {
  final List<WorkoutSession> sessions;
  final bool isDark;
  final AppLocalizations l10n;

  const _ExerciseRecordsList({
    required this.sessions,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(sessionRepositoryProvider);

    return FutureBuilder<List<ExerciseRecordWithSession>>(
      future: _getAllExerciseRecords(repo),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final exerciseRecords = snapshot.data!;
        
        if (exerciseRecords.isEmpty) {
          return Center(
            child: Text(
              l10n.noData,
              style: TextStyle(
                color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
              ),
            ),
          );
        }

        // Group by exercise for display
        return ListView.builder(
          itemCount: exerciseRecords.length,
          itemBuilder: (context, index) {
            return ExerciseRecordCard(
              exerciseRecord: exerciseRecords[index],
              isDark: isDark,
              l10n: l10n,
            );
          },
        );
      },
    );
  }

  Future<List<ExerciseRecordWithSession>> _getAllExerciseRecords(SessionRepository repo) async {
    final List<ExerciseRecordWithSession> allRecords = [];

    for (final session in sessions) {
      final records = await repo.getRecordsBySession(session.id);
      for (final record in records) {
        final exercise = await repo.getExerciseById(record.exerciseId);
        if (exercise != null) {
          final bodyPart = await repo.getBodyPartById(exercise.bodyPartId);
          final sets = await repo.getSetsByExerciseRecord(record.id);
          allRecords.add(ExerciseRecordWithSession(
            record: record,
            session: session,
            exercise: exercise,
            bodyPart: bodyPart,
            sets: sets,
          ));
        }
      }
    }

    // Sort by session start time
    allRecords.sort((a, b) => a.session.startTime.compareTo(b.session.startTime));
    
    return allRecords;
  }
}
