import '../../data/database/database.dart';

/// Data class for exercise record with session info (used in Calendar page)
class ExerciseRecordWithSession {
  final ExerciseRecord record;
  final WorkoutSession session;
  final Exercise? exercise;  // Nullable for body-part-only records
  final BodyPart? bodyPart;
  final List<SetRecord> sets;

  ExerciseRecordWithSession({
    required this.record,
    required this.session,
    this.exercise,  // Nullable for body-part-only records
    required this.bodyPart,
    required this.sets,
  });
}
