enum MuscleGroup {
  chest('Chest', '胸'),
  back('Back', '背'),
  legs('Legs', '腿'),
  shoulders('Shoulders', '肩'),
  arms('Arms', '手臂'),
  glutes('Glutes', '臀'),
  abs('Abs', '腹'),
  rest('Rest', '休息');

  final String english;
  final String chinese;

  const MuscleGroup(this.english, this.chinese);

  String getName(bool isChinese) {
    return isChinese ? chinese : english;
  }

  // Get translated name based on locale code
  String getLocalizedName(String locale) {
    return locale.startsWith('zh') ? chinese : english;
  }

  // Get English name
  String get englishName => english;

  // Get Chinese name
  String get chineseName => chinese;
  
  // Base recovery time in hours
  int get baseRecoveryHours {
    switch (this) {
      case MuscleGroup.chest:
      case MuscleGroup.back:
      case MuscleGroup.legs:
        return 72;
      case MuscleGroup.shoulders:
        return 48;
      case MuscleGroup.arms:
      case MuscleGroup.glutes:
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
      case MuscleGroup.legs:
        return 1.0;
      case MuscleGroup.shoulders:
        return 0.8;
      case MuscleGroup.arms:
      case MuscleGroup.glutes:
      case MuscleGroup.abs:
        return 0.6;
      case MuscleGroup.rest:
        return 0.0;
    }
  }
}
