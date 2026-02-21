import '../../core/enums/muscle_enum.dart';

/// Utility class for MuscleGroup related operations
/// This replaces duplicated _getMuscleGroupByName methods across multiple files
class MuscleGroupHelper {
  /// Map body part name to MuscleGroup for color display
  /// Handles both English and Chinese names
  static MuscleGroup getMuscleGroupByName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('chest') || lowerName.contains('胸')) {
      return MuscleGroup.chest;
    } else if (lowerName.contains('back') || lowerName.contains('背')) {
      return MuscleGroup.back;
    } else if (lowerName.contains('shoulder') || lowerName.contains('肩')) {
      return MuscleGroup.shoulders;
    } else if (lowerName.contains('leg') || lowerName.contains('腿')) {
      return MuscleGroup.legs;
    } else if (lowerName.contains('arm') || lowerName.contains('臂')) {
      return MuscleGroup.arms;
    } else if (lowerName.contains('glute') || lowerName.contains('臀')) {
      return MuscleGroup.glutes;
    } else if (lowerName.contains('abs') || lowerName.contains('腹')) {
      return MuscleGroup.abs;
    }
    return MuscleGroup.rest;
  }

  /// Check if a body part name represents a rest day
  static bool isRest(String name) {
    final lowerName = name.toLowerCase();
    return lowerName.contains('rest') || lowerName.contains('休息');
  }
}
