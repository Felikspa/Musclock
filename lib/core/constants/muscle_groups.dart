import '../../core/enums/muscle_enum.dart';

// Common exercises grouped by muscle
class ExerciseDatabase {
  static const Map<MuscleGroup, Map<String, String>> exercisesByMuscle = {
    MuscleGroup.chest: {
      'Bench Press': '卧推',
      'Incline Bench Press': '上斜卧推',
      'Decline Bench Press': '下斜卧推',
      'Dumbbell Fly': '哑铃飞鸟',
      'Cable Crossover': '绳索夹胸',
      'Push-ups': '俯卧撑',
      'Dips': '双杠臂屈伸',
    },
    MuscleGroup.back: {
      'Deadlift': '硬拉',
      'Pull-ups': '引体向上',
      'Lat Pulldown': '高位下拉',
      'Barbell Row': '杠铃划船',
      'Dumbbell Row': '哑铃划船',
      'Seated Cable Row': '坐姿绳索划船',
      'T-Bar Row': 'T杠划船',
    },
    MuscleGroup.legs: {
      'Squat': '深蹲',
      'Leg Press': '腿举',
      'Lunges': '弓步',
      'Leg Extension': '腿伸展',
      'Leg Curl': '腿弯举',
      'Calf Raise': '提踵',
      'Romanian Deadlift': '罗马尼亚硬拉',
      'Hip Thrust': '臀推',
    },
    MuscleGroup.shoulders: {
      'Overhead Press': '肩上推举',
      'Dumbbell Shoulder Press': '哑铃肩推',
      'Lateral Raise': '侧平举',
      'Front Raise': '前平举',
      'Rear Delt Fly': '俯身飞鸟',
      'Face Pull': '面拉',
      'Shrugs': '耸肩',
    },
    MuscleGroup.arms: {
      'Barbell Curl': '杠铃弯举',
      'Dumbbell Curl': '哑铃弯举',
      'Hammer Curl': '锤式弯举',
      'Tricep Pushdown': '三头下压',
      'Tricep Dips': '三头臂屈伸',
      'Skull Crusher': ' Skull Crusher',
      'Preacher Curl': '牧师凳弯举',
    },
  };

  static List<String> getExercisesForMuscle(MuscleGroup muscle) {
    return exercisesByMuscle[muscle]?.keys.toList() ?? [];
  }

  static Map<String, String> getExerciseNamesForMuscle(MuscleGroup muscle) {
    return exercisesByMuscle[muscle] ?? {};
  }

  static String getExerciseName(String englishName, bool isChinese) {
    for (var entry in exercisesByMuscle.entries) {
      if (entry.value.containsKey(englishName)) {
        return isChinese ? entry.value[englishName]! : englishName;
      }
    }
    return englishName;
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
