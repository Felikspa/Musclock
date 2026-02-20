import 'package:uuid/uuid.dart';

class SetRecordEntity {
  final String id;
  final String exerciseRecordId;
  final double weight;
  final int reps;
  final int orderIndex;

  SetRecordEntity({
    String? id,
    required this.exerciseRecordId,
    required this.weight,
    required this.reps,
    required this.orderIndex,
  }) : id = id ?? const Uuid().v4();

  SetRecordEntity copyWith({
    String? id,
    String? exerciseRecordId,
    double? weight,
    int? reps,
    int? orderIndex,
  }) {
    return SetRecordEntity(
      id: id ?? this.id,
      exerciseRecordId: exerciseRecordId ?? this.exerciseRecordId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  double get volume => weight * reps;

  Map<String, dynamic> toJson() => {
        'id': id,
        'exerciseRecordId': exerciseRecordId,
        'weight': weight,
        'reps': reps,
        'orderIndex': orderIndex,
      };

  factory SetRecordEntity.fromJson(Map<String, dynamic> json) => SetRecordEntity(
        id: json['id'] as String,
        exerciseRecordId: json['exerciseRecordId'] as String,
        weight: (json['weight'] as num).toDouble(),
        reps: json['reps'] as int,
        orderIndex: json['orderIndex'] as int,
      );
}
