import 'dart:convert';
import 'package:uuid/uuid.dart';

class ExerciseEntity {
  final String id;
  final String name;
  final List<String> bodyPartIds;
  final DateTime createdAt;

  ExerciseEntity({
    String? id,
    required this.name,
    required this.bodyPartIds,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toUtc();

  ExerciseEntity copyWith({
    String? id,
    String? name,
    List<String>? bodyPartIds,
    DateTime? createdAt,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPartIds: bodyPartIds ?? this.bodyPartIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get the primary body part ID (first in the list)
  String? get primaryBodyPartId => bodyPartIds.isNotEmpty ? bodyPartIds.first : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bodyPartIds': bodyPartIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ExerciseEntity.fromJson(Map<String, dynamic> json) => ExerciseEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        bodyPartIds: (json['bodyPartIds'] is List) 
            ? List<String>.from(json['bodyPartIds']) 
            : _parseBodyPartIds(json['bodyPartIds'] as String? ?? '[]'),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// Parse bodyPartIds from JSON string or List
  static List<String> _parseBodyPartIds(String? jsonString) {
    // Handle NULL or empty values
    if (jsonString == null || jsonString.isEmpty || jsonString == '[]') return [];
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
