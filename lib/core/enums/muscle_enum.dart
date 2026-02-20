enum MuscleGroup {
  chest('Chest', '胸'),
  back('Back', '背'),
  glutes('Glutes', '臀'),
  legs('Legs', '腿'),
  shoulders('Shoulders', '肩'),
  arms('Arms', '臂'),
  abs('Abs', '腹'),
  rest('Rest', '休息');

  final String english;
  final String chinese;
  
  const MuscleGroup(this.english, this.chinese);
  
  // Base recovery time in hours
  int get baseRecoveryHours {
    switch (this) {
      case MuscleGroup.chest:
      case MuscleGroup.back:
      case MuscleGroup.glutes:
      case MuscleGroup.legs:
        return 72;
      case MuscleGroup.shoulders:
        return 48;
      case MuscleGroup.arms:
      case MuscleGroup.abs:
        return 24;
      case MuscleGroup.rest:
        return 0;
    }
  }
  
  // Get recovery multiplier based on training intensity
  double get recoveryMultiplier {
    switch (this) {
      case MuscleGroup.chest:
      case MuscleGroup.back:
      case MuscleGroup.glutes:
      case MuscleGroup.legs:
        return 1.0;
      case MuscleGroup.shoulders:
        return 0.8;
      case MuscleGroup.arms:
      case MuscleGroup.abs:
        return 0.6;
      case MuscleGroup.rest:
        return 0.0;
    }
  }
}
