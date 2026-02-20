import 'package:uuid/uuid.dart';

class ExerciseRecordEntity {
  final String id;
  final String sessionId;
  final String exerciseId;

  ExerciseRecordEntity({
    String? id,
    required this.sessionId,
    required this.exerciseId,
  }) : id = id ?? const Uuid().v4();

  ExerciseRecordEntity copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
  }) {
    return ExerciseRecordEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'exerciseId': exerciseId,
      };

  factory ExerciseRecordEntity.fromJson(Map<String, dynamic> json) => ExerciseRecordEntity(
        id: json['id'] as String,
        sessionId: json['sessionId'] as String,
        exerciseId: json['exerciseId'] as String,
      );
}
