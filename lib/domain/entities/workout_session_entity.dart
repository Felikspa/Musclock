import 'package:uuid/uuid.dart';

class WorkoutSessionEntity {
  final String id;
  final DateTime startTime;
  final DateTime createdAt;

  WorkoutSessionEntity({
    String? id,
    DateTime? startTime,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now().toUtc(),
        createdAt = createdAt ?? DateTime.now().toUtc();

  WorkoutSessionEntity copyWith({
    String? id,
    DateTime? startTime,
    DateTime? createdAt,
  }) {
    return WorkoutSessionEntity(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory WorkoutSessionEntity.fromJson(Map<String, dynamic> json) => WorkoutSessionEntity(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
