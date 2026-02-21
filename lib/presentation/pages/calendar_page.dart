import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/enums/muscle_enum.dart';
import '../../data/database/database.dart';
import '../../domain/entities/exercise_record_with_session.dart';
import '../providers/providers.dart';
import '../widgets/training_details_dialog.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
    final db = ref.read(databaseProvider);
    final muscleNames = <String>[];
    
    for (final session in sessions) {
      final records = await db.getRecordsBySession(session.id);
      for (final record in records) {
        final exercise = await db.getExerciseById(record.exerciseId);
        if (exercise != null) {
          final bodyPart = await db.getBodyPartById(exercise.bodyPartId);
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
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<ExerciseRecordWithSession>>(
      future: _getAllExerciseRecords(db),
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
            return _ExerciseRecordCard(
              exerciseRecord: exerciseRecords[index],
              isDark: isDark,
              l10n: l10n,
            );
          },
        );
      },
    );
  }

  Future<List<ExerciseRecordWithSession>> _getAllExerciseRecords(AppDatabase db) async {
    final List<ExerciseRecordWithSession> allRecords = [];

    for (final session in sessions) {
      final records = await db.getRecordsBySession(session.id);
      for (final record in records) {
        final exercise = await db.getExerciseById(record.exerciseId);
        if (exercise != null) {
          final bodyPart = await db.getBodyPartById(exercise.bodyPartId);
          final sets = await db.getSetsByExerciseRecord(record.id);
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

// Individual exercise record card with color chips and details dialog
class _ExerciseRecordCard extends StatelessWidget {
  final ExerciseRecordWithSession exerciseRecord;
  final bool isDark;
  final AppLocalizations l10n;

  const _ExerciseRecordCard({
    required this.exerciseRecord,
    required this.isDark,
    required this.l10n,
  });

  /// Map body part name to MuscleGroup for color display
  MuscleGroup _getMuscleGroupByName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('chest') || lowerName.contains('胸')) {
      return MuscleGroup.chest;
    } else if (lowerName.contains('back') || lowerName.contains('背')) {
      return MuscleGroup.back;
    } else if (lowerName.contains('shoulder') || lowerName.contains('肩')) {
      return MuscleGroup.shoulders;
    } else if (lowerName.contains('leg') || lowerName.contains('腿')) {
      return MuscleGroup.legs;
    } else if (lowerName.contains('arm') || lowerName.contains('臂')) {
      return MuscleGroup.arms;
    } else if (lowerName.contains('glute') || lowerName.contains('臀')) {
      return MuscleGroup.glutes;
    } else if (lowerName.contains('abs') || lowerName.contains('腹')) {
      return MuscleGroup.abs;
    }
    return MuscleGroup.rest;
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final exercise = exerciseRecord;
    final bodyPartName = exercise.bodyPart?.name ?? '';
    final exerciseName = exercise.exercise.name;

    // Get muscle color
    final muscleGroup = _getMuscleGroupByName(bodyPartName);
    final muscleColor = AppTheme.getMuscleColor(muscleGroup);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          // Show details dialog instead of expanding
          showDialog(
            context: context,
            builder: (context) => TrainingDetailsDialog(
              exerciseRecord: exerciseRecord,
              isDark: isDark,
              l10n: l10n,
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Body part color chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: muscleColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  bodyPartName,
                  style: TextStyle(
                    color: muscleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Exercise name and sets info
              Expanded(
                child: exercise.sets.isNotEmpty
                    ? Text(
                        '$exerciseName • ${exercise.sets.length} sets',
                        style: TextStyle(
                          color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        exerciseName,
                        style: TextStyle(
                          color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              const SizedBox(width: 8),
              // Time on the right
              Text(
                timeFormat.format(exercise.session.startTime),
                style: TextStyle(
                  color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends ConsumerStatefulWidget {
  final WorkoutSession session;
  final bool isDark;
  final AppLocalizations l10n;

  const _SessionCard({
    required this.session,
    required this.isDark,
    required this.l10n,
  });

  @override
  ConsumerState<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends ConsumerState<_SessionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(_recordsProvider(widget.session.id));
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: recordsAsync.when(
        data: (records) => _buildContent(context, records, timeFormat),
        loading: () => const Padding(
          padding: EdgeInsets.all(12),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, s) => Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Error: $e'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ExerciseRecord> records, DateFormat timeFormat) {
    return FutureBuilder<_SessionDisplayDataCalendar>(
      future: _getSessionDisplayData(records),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;

        return Column(
          children: [
            // Clickable header
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Body parts on left (large), time on right (small gray)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main title: body parts
                        Expanded(
                          child: Text(
                            data.bodyParts.isNotEmpty ? data.bodyParts.join(' + ') : widget.l10n.noData,
                            style: TextStyle(
                              color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Time on right
                        Text(
                          timeFormat.format(widget.session.startTime),
                          style: TextStyle(
                            color: widget.isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Expand icon
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                          color: widget.isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content - exercise details
            if (_isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise details
                    ...data.exercises.map((exercise) => _buildExerciseItem(context, exercise)),
                    
                    const SizedBox(height: 8),
                    
                    // Edit button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _editSession(context),
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(widget.l10n.edit),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildExerciseItem(BuildContext context, _ExerciseWithSetsCalendar exercise) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name
          Text(
            exercise.name,
            style: TextStyle(
              color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Sets - only show if there are sets
          if (exercise.sets.isNotEmpty) ...[
            const SizedBox(height: 2),
            Wrap(
              spacing: 6,
              runSpacing: 2,
              children: exercise.sets.map((set) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${set.weight}kg x ${set.reps}',
                    style: TextStyle(
                      color: widget.isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Future<_SessionDisplayDataCalendar> _getSessionDisplayData(List<ExerciseRecord> records) async {
    final db = ref.read(databaseProvider);
    final Map<String, _ExerciseWithSetsCalendar> exerciseMap = {};
    final Set<String> bodyParts = {};

    for (final record in records) {
      final exercise = await db.getExerciseById(record.exerciseId);
      if (exercise != null) {
        final bodyPart = await db.getBodyPartById(exercise.bodyPartId);
        if (bodyPart != null) {
          bodyParts.add(bodyPart.name);
        }
        
        // Get sets for this record
        final sets = await db.getSetsByExerciseRecord(record.id);
        
        if (exerciseMap.containsKey(exercise.id)) {
          exerciseMap[exercise.id]!.sets.addAll(sets);
        } else {
          exerciseMap[exercise.id] = _ExerciseWithSetsCalendar(
            name: exercise.name,
            sets: sets,
          );
        }
      }
    }

    return _SessionDisplayDataCalendar(
      bodyParts: bodyParts.toList(),
      exercises: exerciseMap.values.toList(),
    );
  }

  void _editSession(BuildContext context) {
    // TODO: Navigate to edit session view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }
}

// Data class for calendar session display
class _SessionDisplayDataCalendar {
  final List<String> bodyParts;
  final List<_ExerciseWithSetsCalendar> exercises;

  _SessionDisplayDataCalendar({
    required this.bodyParts,
    required this.exercises,
  });
}

class _ExerciseWithSetsCalendar {
  final String name;
  final List<SetRecord> sets;

  _ExerciseWithSetsCalendar({
    required this.name,
    required this.sets,
  });
}

final _recordsProvider = FutureProvider.family<List<ExerciseRecord>, String>((ref, sessionId) async {
  final db = ref.watch(databaseProvider);
  return db.getRecordsBySession(sessionId);
});

class _ExerciseChip extends ConsumerWidget {
  final String recordId;
  final bool isDark;

  const _ExerciseChip({
    required this.recordId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(_recordsProvider(recordId));

    return recordsAsync.when(
      data: (records) {
        if (records.isEmpty) return const SizedBox.shrink();
        final record = records.first;
        final exerciseAsync = ref.watch(_exerciseProvider(record.exerciseId));

        return exerciseAsync.when(
          data: (exercise) {
            if (exercise == null) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                exercise.name,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

final _exerciseProvider = FutureProvider.family<Exercise?, String>((ref, exerciseId) async {
  final db = ref.watch(databaseProvider);
  return db.getExerciseById(exerciseId);
});
