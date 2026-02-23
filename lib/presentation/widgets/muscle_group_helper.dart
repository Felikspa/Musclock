import 'package:flutter/material.dart';
import '../../core/enums/muscle_enum.dart';
import '../../core/theme/app_theme.dart';

/// Utility class for MuscleGroup related operations
/// This replaces duplicated _getMuscleGroupByName methods across multiple files
class MuscleGroupHelper {
  /// Map body part name to MuscleGroup for color display
  /// Handles both English and Chinese names
  /// Returns null for unknown/custom body parts (not rest)
  static MuscleGroup? getMuscleGroupByName(String name) {
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
    // Return null for unknown/custom body parts instead of rest
    return null;
  }

  /// Get color for a body part name
  /// For known muscle groups, returns the corresponding color
  /// For unknown/custom body parts, generates a consistent color based on the name
  static Color getColorForBodyPart(String name) {
    final muscleGroup = getMuscleGroupByName(name);
    if (muscleGroup != null) {
      return AppTheme.getMuscleColor(muscleGroup);
    }
    // Generate a consistent color for unknown/custom body parts
    return AppTheme.getColorFromName(name);
  }

  /// Check if a body part name represents a rest day
  static bool isRest(String name) {
    final lowerName = name.toLowerCase();
    return lowerName.contains('rest') || lowerName.contains('休息');
  }
}
