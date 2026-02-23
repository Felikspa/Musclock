import '../enums/muscle_enum.dart';

/// Muscle constants for heatmap calculation
/// Contains weights, difficulty coefficients, and helper methods
class MuscleConstants {
  // Major muscle groups: weight 10
  static const Set<MuscleGroup> majorMuscles = {
    MuscleGroup.chest,
    MuscleGroup.back,
    MuscleGroup.legs,
    MuscleGroup.glutes,
  };

  // Minor muscle groups: weight 6
  static const Set<MuscleGroup> minorMuscles = {
    MuscleGroup.shoulders,
    MuscleGroup.arms,
    MuscleGroup.abs,
  };

  // Major muscle group weight
  static const int majorWeight = 10;

  // Minor muscle group weight
  static const int minorWeight = 6;

  // Exercise difficulty coefficients
  // Compound exercises: 1.2, Isolation exercises: 0.8
  static const Map<String, double> exerciseDifficulty = {
    // Compound exercises (1.2)
    'squat': 1.2,
    'Squat': 1.2,
    '深蹲': 1.2,
    'deadlift': 1.2,
    'Deadlift': 1.2,
    '硬拉': 1.2,
    'bench press': 1.2,
    'Bench Press': 1.2,
    '卧推': 1.2,
    'overhead press': 1.2,
    'Overhead Press': 1.2,
    '肩上推举': 1.2,
    'barbell row': 1.2,
    'Barbell Row': 1.2,
    '杠铃划船': 1.2,
    'leg press': 1.2,
    'Leg Press': 1.2,
    '腿举': 1.2,
    'hip thrust': 1.2,
    'Hip Thrust': 1.2,
    '臀推': 1.2,
    'pull-ups': 1.2,
    'Pull-ups': 1.2,
    '引体向上': 1.2,
    'dips': 1.2,
    'Dips': 1.2,
    '双杠臂屈伸': 1.2,

    // Isolation exercises (0.8)
    'fly': 0.8,
    'Fly': 0.8,
    '哑铃飞鸟': 0.8,
    'curl': 0.8,
    'Curl': 0.8,
    '弯举': 0.8,
    'extension': 0.8,
    'Extension': 0.8,
    '腿伸展': 0.8,
    'lateral raise': 0.8,
    'Lateral Raise': 0.8,
    '侧平举': 0.8,
    'cable crossover': 0.8,
    'Cable Crossover': 0.8,
    '绳索夹胸': 0.8,
    'leg curl': 0.8,
    'Leg Curl': 0.8,
    '腿弯举': 0.8,
    'tricep pushdown': 0.8,
    'Tricep Pushdown': 0.8,
    '三头下压': 0.8,
  };

  /// Get muscle weight based on MuscleGroup enum
  static int getMuscleWeight(MuscleGroup muscle) {
    if (majorMuscles.contains(muscle)) {
      return majorWeight;
    }
    return minorWeight;
  }

  /// Get muscle weight from string (bodyPartId or name)
  static int getMuscleWeightByName(String muscleName) {
    // Try to parse as MuscleGroup enum first
    final muscle = MuscleGroup.values.cast<MuscleGroup?>().firstWhere(
      (m) => m?.name.toLowerCase() == muscleName.toLowerCase() ||
             m?.chinese == muscleName ||
             m?.english == muscleName,
      orElse: () => null,
    );

    if (muscle != null) {
      return getMuscleWeight(muscle);
    }

    // Fallback: check by string matching
    final lowerName = muscleName.toLowerCase();
    if (majorMuscles.any((m) => m.name.toLowerCase() == lowerName || m.chinese == muscleName)) {
      return majorWeight;
    }
    if (minorMuscles.any((m) => m.name.toLowerCase() == lowerName || m.chinese == muscleName)) {
      return minorWeight;
    }

    return minorWeight; // Default weight
  }

  /// Get exercise difficulty coefficient
  static double getExerciseDifficulty(String exerciseName) {
    return exerciseDifficulty[exerciseName] ?? 1.0;
  }

  /// Calculate decay factor for multiple muscles
  /// Uses square root to prevent excessive points when training many muscles
  static double calculateDecayFactor(int muscleCount) {
    if (muscleCount <= 1) return 1.0;
    // Square root decay: 1 muscle = 1.0, 4 muscles = 0.5, 9 muscles = 0.33
    return 1.0 / _sqrt(muscleCount);
  }

  /// Simple square root approximation using Newton's method
  static double _sqrt(int n) {
    if (n <= 0) return 1.0;
    double x = n.toDouble();
    double y = (x + 1) / 2;
    while (y < x) {
      x = y;
      y = (x + n / x) / 2;
    }
    return x;
  }
}
