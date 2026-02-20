import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/database.dart';
import '../providers/providers.dart';

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
              child: ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  return _SessionCard(
                    session: sessions[index],
                    isDark: isDark,
                    l10n: l10n,
                  );
                },
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

class _SessionCard extends ConsumerWidget {
  final WorkoutSession session;
  final bool isDark;
  final AppLocalizations l10n;

  const _SessionCard({
    required this.session,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(_recordsProvider(session.id));
    final bodyPartsAsync = ref.watch(_sessionBodyPartsProvider(session.id));
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.secondaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Show body parts in primary position
              Expanded(
                child: bodyPartsAsync.when(
                  data: (bodyParts) {
                    if (bodyParts.isEmpty) {
                      return Text(
                        l10n.noData,
                        style: TextStyle(
                          color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }
                    return Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: bodyParts.map((bp) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bp,
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    );
                  },
                  loading: () => const Text('...'),
                  error: (_, __) => Text(l10n.noData),
                ),
              ),
              // Time in secondary position
              Row(
                children: [
                  Text(
                    timeFormat.format(session.startTime),
                    style: TextStyle(
                      color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showEditSessionSheet(context, ref),
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Show exercise names below
          recordsAsync.when(
            data: (records) {
              if (records.isEmpty) {
                return const SizedBox.shrink();
              }
              return Wrap(
                spacing: 4,
                runSpacing: 4,
                children: records.map((record) {
                  return _ExerciseChip(exerciseId: record.exerciseId, isDark: isDark);
                }).toList(),
              );
            },
            loading: () => const Text('...'),
            error: (e, s) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  void _showEditSessionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _CalendarEditSessionSheet(
          scrollController: scrollController,
          session: session,
          l10n: l10n,
        ),
      ),
    );
  }
}

final _recordsProvider = FutureProvider.family<List<ExerciseRecord>, String>((ref, sessionId) async {
  final db = ref.watch(databaseProvider);
  return db.getRecordsBySession(sessionId);
});

class _ExerciseChip extends ConsumerWidget {
  final String exerciseId;
  final bool isDark;

  const _ExerciseChip({
    required this.exerciseId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(_exerciseProvider(exerciseId));

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
  }
}

final _exerciseProvider = FutureProvider.family<Exercise?, String>((ref, exerciseId) async {
  final db = ref.watch(databaseProvider);
  return db.getExerciseById(exerciseId);
});

// Provider to get body part names for a session
final _sessionBodyPartsProvider = FutureProvider.family<List<String>, String>((ref, sessionId) async {
  final db = ref.watch(databaseProvider);
  final records = await db.getRecordsBySession(sessionId);
  final bodyPartNames = <String>[];
  
  for (final record in records) {
    final exercise = await db.getExerciseById(record.exerciseId);
    if (exercise != null) {
      final bodyPart = await db.getBodyPartById(exercise.bodyPartId);
      if (bodyPart != null && !bodyPartNames.contains(bodyPart.name)) {
        bodyPartNames.add(bodyPart.name);
      }
    }
  }
  return bodyPartNames;
});

class _CalendarEditSessionSheet extends ConsumerWidget {
  final ScrollController scrollController;
  final WorkoutSession session;
  final AppLocalizations l10n;

  const _CalendarEditSessionSheet({
    required this.scrollController,
    required this.session,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(_recordsProvider(session.id));

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.sessionDetails,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: recordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return Center(child: Text(l10n.noData));
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return _CalendarEditableExerciseCard(
                      record: records[index],
                      l10n: l10n,
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showDeleteSessionDialog(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(l10n.delete),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSessionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.no),
          ),
          FilledButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              final records = await db.getRecordsBySession(session.id);
              for (final record in records) {
                await db.deleteSetsByExerciseRecord(record.id);
              }
              await db.deleteRecordsBySession(session.id);
              await db.deleteSession(session.id);
              ref.invalidate(sessionsProvider);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
              }
            },
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }
}

class _CalendarEditableExerciseCard extends ConsumerWidget {
  final ExerciseRecord record;
  final AppLocalizations l10n;

  const _CalendarEditableExerciseCard({
    required this.record,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(_exerciseProvider(record.id));
    final setsAsync = ref.watch(_setsProvider(record.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            exerciseAsync.when(
              data: (exercise) => Text(
                exercise?.name ?? 'Unknown',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              loading: () => const Text('...'),
              error: (_, __) => const Text('Error'),
            ),
            const Divider(),
            setsAsync.when(
              data: (sets) {
                return Column(
                  children: sets.asMap().entries.map((entry) {
                    final setIndex = entry.key;
                    final set = entry.value;
                    return _CalendarEditableSetRow(
                      set: set,
                      setIndex: setIndex,
                      recordId: record.id,
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showAddSetDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addSets),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSetDialog(BuildContext context, WidgetRef ref) {
    final weightController = TextEditingController(text: '0');
    final repsController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addSets),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: l10n.weight),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: repsController,
              decoration: InputDecoration(labelText: l10n.reps),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final weight = double.tryParse(weightController.text) ?? 0;
              final reps = int.tryParse(repsController.text) ?? 0;
              if (weight > 0 && reps > 0) {
                final db = ref.read(databaseProvider);
                final sets = await db.getSetsByExerciseRecord(record.id);
                await db.insertSetRecord(SetRecordsCompanion.insert(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  exerciseRecordId: record.id,
                  weight: weight,
                  reps: reps,
                  orderIndex: sets.length,
                ));
                ref.invalidate(_setsProvider(record.id));
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _CalendarEditableSetRow extends ConsumerWidget {
  final SetRecord set;
  final int setIndex;
  final String recordId;

  const _CalendarEditableSetRow({
    required this.set,
    required this.setIndex,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            child: Text(
              '${set.orderIndex + 1}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Text('${set.weight} kg'),
          const SizedBox(width: 8),
          Text('x ${set.reps}'),
          const Spacer(),
          Text(
            '${(set.weight * set.reps).toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await db.deleteSetRecord(set.id);
              ref.invalidate(_setsProvider(recordId));
            },
          ),
        ],
      ),
    );
  }
}

final _setsProvider = FutureProvider.family<List<SetRecord>, String>((ref, exerciseRecordId) async {
  final db = ref.watch(databaseProvider);
  return db.getSetsByExerciseRecord(exerciseRecordId);
});
