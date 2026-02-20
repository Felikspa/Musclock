import '../../core/enums/muscle_enum.dart';

// Common exercises grouped by muscle
class ExerciseDatabase {
  static const Map<MuscleGroup, List<String>> exercisesByMuscle = {
    MuscleGroup.chest: [
      'Bench Press',
      'Incline Bench Press',
      'Decline Bench Press',
      'Dumbbell Fly',
      'Cable Crossover',
      'Push-ups',
      'Dips',
    ],
    MuscleGroup.back: [
      'Deadlift',
      'Pull-ups',
      'Lat Pulldown',
      'Barbell Row',
      'Dumbbell Row',
      'Seated Cable Row',
      'T-Bar Row',
    ],
    MuscleGroup.legs: [
      'Squat',
      'Leg Press',
      'Lunges',
      'Leg Extension',
      'Leg Curl',
      'Calf Raise',
      'Romanian Deadlift',
      'Hip Thrust',
    ],
    MuscleGroup.shoulders: [
      'Overhead Press',
      'Dumbbell Shoulder Press',
      'Lateral Raise',
      'Front Raise',
      'Rear Delt Fly',
      'Face Pull',
      'Shrugs',
    ],
    MuscleGroup.arms: [
      'Barbell Curl',
      'Dumbbell Curl',
      'Hammer Curl',
      'Tricep Pushdown',
      'Tricep Dips',
      'Skull Crusher',
      'Preacher Curl',
    ],
  };
  
  static List<String> getExercisesForMuscle(MuscleGroup muscle) {
    return exercisesByMuscle[muscle] ?? [];
  }
}

// Workout plan templates
class WorkoutTemplates {
  static const Map<String, Map<int, List<MuscleGroup>>> templates = {
    'PPL': {
      // Push Day
      1: [MuscleGroup.chest, MuscleGroup.shoulders, MuscleGroup.arms],
      // Pull Day  
      2: [MuscleGroup.back, MuscleGroup.arms],
      // Leg Day
      3: [MuscleGroup.legs],
      // Rest
      4: [MuscleGroup.rest],
      // Push Day
      5: [MuscleGroup.chest, MuscleGroup.shoulders, MuscleGroup.arms],
      // Pull Day
      6: [MuscleGroup.back, MuscleGroup.arms],
      // Leg Day
      7: [MuscleGroup.legs],
    },
    'Upper/Lower': {
      // Upper
      1: [MuscleGroup.chest, MuscleGroup.back, MuscleGroup.shoulders, MuscleGroup.arms],
      // Lower
      2: [MuscleGroup.legs],
      // Rest
      3: [MuscleGroup.rest],
      // Upper
      4: [MuscleGroup.chest, MuscleGroup.back, MuscleGroup.shoulders, MuscleGroup.arms],
      // Lower
      5: [MuscleGroup.legs],
      // Rest
      6: [MuscleGroup.rest],
      // Rest
      7: [MuscleGroup.rest],
    },
    'Bro Split': {
      // Chest
      1: [MuscleGroup.chest],
      // Back
      2: [MuscleGroup.back],
      // Legs
      3: [MuscleGroup.legs],
      // Shoulders
      4: [MuscleGroup.shoulders],
      // Arms
      5: [MuscleGroup.arms],
      // Rest
      6: [MuscleGroup.rest],
      // Rest
      7: [MuscleGroup.rest],
    },
  };
  
  static List<String> get templateNames => templates.keys.toList();
  
  static Map<int, List<MuscleGroup>>? getSchedule(String templateName) {
    return templates[templateName];
  }
}
