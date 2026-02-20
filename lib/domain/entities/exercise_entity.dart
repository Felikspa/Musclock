import 'package:uuid/uuid.dart';

class ExerciseEntity {
  final String id;
  final String name;
  final String bodyPartId;
  final DateTime createdAt;

  ExerciseEntity({
    String? id,
    required this.name,
    required this.bodyPartId,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toUtc();

  ExerciseEntity copyWith({
    String? id,
    String? name,
    String? bodyPartId,
    DateTime? createdAt,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPartId: bodyPartId ?? this.bodyPartId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bodyPartId': bodyPartId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ExerciseEntity.fromJson(Map<String, dynamic> json) => ExerciseEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        bodyPartId: json['bodyPartId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
