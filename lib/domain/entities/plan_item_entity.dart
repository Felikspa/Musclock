import 'package:uuid/uuid.dart';

class PlanItemEntity {
  final String id;
  final String planId;
  final int dayIndex;
  final List<String> bodyPartIds;

  PlanItemEntity({
    String? id,
    required this.planId,
    required this.dayIndex,
    required this.bodyPartIds,
  }) : id = id ?? const Uuid().v4();

  PlanItemEntity copyWith({
    String? id,
    String? planId,
    int? dayIndex,
    List<String>? bodyPartIds,
  }) {
    return PlanItemEntity(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      dayIndex: dayIndex ?? this.dayIndex,
      bodyPartIds: bodyPartIds ?? this.bodyPartIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'dayIndex': dayIndex,
        'bodyPartIds': bodyPartIds,
      };

  factory PlanItemEntity.fromJson(Map<String, dynamic> json) => PlanItemEntity(
        id: json['id'] as String,
        planId: json['planId'] as String,
        dayIndex: json['dayIndex'] as int,
        bodyPartIds: (json['bodyPartIds'] as List<dynamic>).cast<String>(),
      );
}
