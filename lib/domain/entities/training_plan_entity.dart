import 'package:uuid/uuid.dart';

class TrainingPlanEntity {
  final String id;
  final String name;
  final int cycleLengthDays;
  final DateTime createdAt;

  TrainingPlanEntity({
    String? id,
    required this.name,
    required this.cycleLengthDays,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toUtc();

  TrainingPlanEntity copyWith({
    String? id,
    String? name,
    int? cycleLengthDays,
    DateTime? createdAt,
  }) {
    return TrainingPlanEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cycleLengthDays': cycleLengthDays,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TrainingPlanEntity.fromJson(Map<String, dynamic> json) => TrainingPlanEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        cycleLengthDays: json['cycleLengthDays'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
