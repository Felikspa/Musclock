import 'package:uuid/uuid.dart';

class BodyPartEntity {
  final String id;
  final String name;
  final DateTime createdAt;
  final bool isDeleted;

  BodyPartEntity({
    String? id,
    required this.name,
    DateTime? createdAt,
    this.isDeleted = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toUtc();

  BodyPartEntity copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    bool? isDeleted,
  }) {
    return BodyPartEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'isDeleted': isDeleted,
      };

  factory BodyPartEntity.fromJson(Map<String, dynamic> json) => BodyPartEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isDeleted: json['isDeleted'] as bool? ?? false,
      );
}
