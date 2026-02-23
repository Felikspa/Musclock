/// Utility class for Exercise (training items) localization
/// Maps English exercise names to their localized equivalents
class ExerciseHelper {
  /// Map English exercise name to Chinese translation
  static const Map<String, String> _exerciseTranslations = {
    // Legs exercises
    'squat': '深蹲',
    'leg press': '腿举',
    'legpress': '腿举',
    'hack squat': '哈克深蹲',
    'hacksquat': '哈克深蹲',
    'front squat': '前蹲',
    'frontsquat': '前蹲',
    'leg extension': '腿伸展',
    'legextension': '腿伸展',
    'leg curl': '腿弯举',
    'legcurl': '腿弯举',
    'seated leg curl': '坐姿腿弯举',
    'seatedlegcurl': '坐姿腿弯举',
    'lying leg curl': '俯卧腿弯举',
    'lyinglegcurl': '俯卧腿弯举',
    'calf raise': '提踵',
    'calfraise': '提踵',
    'romanian deadlift': '罗马尼亚硬拉',
    'romaniandeadlift': '罗马尼亚硬拉',
    'deadlift': '硬拉',
    'sumo deadlift': '相扑硬拉',
    'sumodeadlift': '相扑硬拉',
    'hip thrust': '臀推',
    'hipthrust': '臀推',
    'glute bridge': '臀桥',
    'glutebridge': '臀桥',
    'lunges': '弓步',
    'lunge': '弓步',
    'walking lunges': '行走弓步',
    'walkinglunges': '行走弓步',
    'bulgarian split squat': '保加利亚分腿蹲',
    'bulgariansplitsquat': '保加利亚分腿蹲',
    'goblet squat': '哑铃深蹲',
    'gobletsquat': '哑铃深蹲',
    'good morning': '早安式',
    'goodmorning': '早安式',
    'abductor': '外展器械',
    'adductor': '内收器械',
    'hip adductor': '内收肌训练',
    'hipadductor': '内收肌训练',

    // Chest exercises
    'bench press': '卧推',
    'benchpress': '卧推',
    'incline bench press': '上斜卧推',
    'inclinebenchpress': '上斜卧推',
    'incline press': '上斜卧推',
    'inclinepress': '上斜卧推',
    'decline bench press': '下斜卧推',
    'declinebenchpress': '下斜卧推',
    'decline press': '下斜卧推',
    'declinepress': '下斜卧推',
    'dumbbell fly': '哑铃飞鸟',
    'dumbbellfly': '哑铃飞鸟',
    'dumbbell press': '哑铃卧推',
    'dumbbellpress': '哑铃卧推',
    'cable fly': '绳索飞鸟',
    'cablefly': '绳索飞鸟',
    'cable crossover': '绳索夹胸',
    'cablecrossover': '绳索夹胸',
    'dips': '双杠臂屈伸',
    'push ups': '俯卧撑',
    'pushups': '俯卧撑',
    'push-up': '俯卧撑',
    'pushup': '俯卧撑',
    'chest press': '器械胸推',
    'chestpress': '器械胸推',
    'machine press': '器械推胸',
    'machinepress': '器械推胸',
    'pec deck': '蝴蝶机夹胸',
    'pecdeck': '蝴蝶机夹胸',
    'smith machine': '史密斯机',
    'smithmachine': '史密斯机',

    // Back exercises
    'pull ups': '引体向上',
    'pullups': '引体向上',
    'pull-up': '引体向上',
    'pullup': '引体向上',
    'chin ups': '反手引体向上',
    'chinups': '反手引体向上',
    'chin-up': '反手引体向上',
    'chinup': '反手引体向上',
    'lat pulldown': '高位下拉',
    'latpulldown': '高位下拉',
    'barbell row': '杠铃划船',
    'barbellrow': '杠铃划船',
    'dumbbell row': '哑铃划船',
    'dumbbellrow': '哑铃划船',
    'seated cable row': '坐姿绳索划船',
    'seatedcablerow': '坐姿绳索划船',
    't bar row': 'T杠划船',
    'tbarrow': 'T杠划船',
    'bent over row': '俯身划船',
    'bentoverrow': '俯身划船',
    'pendlay row': 'Pendlay划船',
    'pendlayrow': 'Pendlay划船',
    'chest supported row': '胸支撑划船',
    'chestsupportedrow': '胸支撑划船',
    'meadows row': 'Meadows划船',
    'meadowsrow': 'Meadows划船',
    'cable pullover': '绳索直臂下拉',
    'cablepullover': '绳索直臂下拉',

    // Shoulders exercises
    'overhead press': '肩上推举',
    'overheadpress': '肩上推举',
    'ohp': '肩上推举',
    'dumbbell shoulder press': '哑铃肩推',
    'dumbbellshoulderpress': '哑铃肩推',
    'arnold press': '阿诺德推举',
    'arnoldpress': '阿诺德推举',
    'machine shoulder press': '器械肩推',
    'machineshoulderpress': '器械肩推',
    'lateral raise': '侧平举',
    'lateralraise': '侧平举',
    'cable lateral raise': '绳索侧平举',
    'cablelateralraise': '绳索侧平举',
    'front raise': '前平举',
    'frontraise': '前平举',
    'rear delt fly': '俯身飞鸟',
    'reardeltfly': '俯身飞鸟',
    'face pull': '面拉',
    'facepull': '面拉',
    'shrugs': '耸肩',
    'shrug': '耸肩',
    'upright row': '直立划船',
    'uprightrow': '直立划船',

    // Arms exercises
    'dumbbell curl': '哑铃弯举',
    'dumbbellcurl': '哑铃弯举',
    'bicep curl': '二头弯举',
    'bicepcurl': '二头弯举',
    'barbell curl': '杠铃弯举',
    'barbellcurl': '杠铃弯举',
    'hammer curl': '锤式弯举',
    'hammercurl': '锤式弯举',
    'preacher curl': '牧师凳弯举',
    'preachercurl': '牧师凳弯举',
    'ez bar curl': 'EZ杆弯举',
    'ezbarcurl': 'EZ杆弯举',
    'concentration curl': '集中弯举',
    'concentrationcurl': '集中弯举',
    'incline dumbbell curl': '上斜哑铃弯举',
    'inclinedumbbellcurl': '上斜哑铃弯举',
    'cable curl': '绳索弯举',
    'cablecurl': '绳索弯举',
    'tricep pushdown': '三头下压',
    'triceppushdown': '三头下压',
    'tricep dips': '三头臂屈伸',
    'tricepdips': '三头臂屈伸',
    'skull crusher': '颅骨碎裂者',
    'skullcrusher': '颅骨碎裂者',
    'tricep extension': '三头屈伸',
    'tricepextension': '三头屈伸',
    'cable tricep extension': '绳索三头屈伸',
    'cable tricepextension': '绳索三头屈伸',
    'close grip bench': '窄距卧推',
    'closegripbench': '窄距卧推',
    'overhead tricep extension': '过头三头屈伸',
    'overheadtricepextension': '过头三头屈伸',
    'cable kickback': '绳索后踢',
    'cablekickback': '绳索后踢',

    // Core exercises
    'crunch': '卷腹',
    'plank': '平板支撑',
    'leg raise': '抬腿',
    'legraise': '抬腿',
    'hanging leg raise': '悬垂抬腿',
    'hanginglegraise': '悬垂抬腿',
    'russian twist': '俄式转体',
    'russiantwist': '俄式转体',
    'sit up': '仰卧起坐',
    'situp': '仰卧起坐',
    'mountain climber': '登山者',
    'mountainclimber': '登山者',
    'dead bug': '死虫式',
    'deadbug': '死虫式',
    'cable woodchop': '绳索伐木',
    'cablewoodchop': '绳索伐木',
    'ab rollout': '腹肌轮',
    'abrollout': '腹肌轮',
  };

  /// Get localized exercise name based on locale code
  /// Returns original name if no translation is available
  static String getLocalizedName(String name, String locale) {
    if (locale.startsWith('zh')) {
      // First try exact match
      if (_exerciseTranslations.containsKey(name)) {
        return _exerciseTranslations[name]!;
      }
      
      // Try normalized versions
      final normalized = name.toLowerCase().replaceAll(' ', '').replaceAll('-', '');
      if (_exerciseTranslations.containsKey(normalized)) {
        return _exerciseTranslations[normalized]!;
      }
      
      // Try with spaces replaced
      final withSpaces = name.toLowerCase().replaceAll('-', ' ');
      if (_exerciseTranslations.containsKey(withSpaces)) {
        return _exerciseTranslations[withSpaces]!;
      }
      
      // Try case-insensitive match
      final lowerName = name.toLowerCase();
      for (final entry in _exerciseTranslations.entries) {
        if (entry.key.toLowerCase() == lowerName) {
          return entry.value;
        }
      }
      
      return name;
    }
    return name;
  }

  /// Check if an exercise name has a translation
  static bool hasTranslation(String name) {
    return _exerciseTranslations.containsKey(name) ||
           _exerciseTranslations.containsKey(name.toLowerCase().replaceAll(' ', '').replaceAll('-', ''));
  }

  /// Get all available exercise translations
  static Map<String, String> get allTranslations => _exerciseTranslations;
}
