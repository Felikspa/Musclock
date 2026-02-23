import '../../data/database/database.dart';
import '../../core/constants/muscle_constants.dart';
import 'dart:convert';

/// Data confidence level enum for training points calculation
enum DataConfidenceLevel {
  /// Level 1: Only body part selected (no sets data)
  level1_BodyPartOnly,
  /// Level 2: Has set count but no weight/reps
  level2_SetCountOnly,
  /// Level 3: Complete data with weight, reps, and sets
  level3_Complete,
}

/// Training Points (TP) calculation use case
/// Implements three-tier confidence-based scoring system for heatmap
class CalculateTrainingPointsUseCase {
  final AppDatabase _db;

  // Intensity coefficients
  static const double level2Multiplier = 1.2;
  static const double level3Multiplier = 1.5;

  CalculateTrainingPointsUseCase(this._db);

  /// Parse bodyPartIds JSON array string to List<String>
  List<String> _parseBodyPartIds(String? bodyPartIdsJson) {
    // Handle NULL or empty values
    if (bodyPartIdsJson == null || bodyPartIdsJson.isEmpty || bodyPartIdsJson == '[]') return [];
    try {
      final decoded = jsonDecode(bodyPartIdsJson);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Level 1: Fuzzy matching (body part only)
  /// TP = Sum(bodyPart weight) * sqrt(decay factor)
  double calculateLevel1(List<String> bodyPartIds) {
    if (bodyPartIds.isEmpty) return 0;

    double totalWeight = 0;
    for (final id in bodyPartIds) {
      final weight = MuscleConstants.getMuscleWeightByName(id);
      totalWeight += weight;
    }

    // Apply decay factor to prevent excessive points when training many muscles
    // sqrt(1) = 1, sqrt(4) = 2, sqrt(9) = 3
    final decayFactor = MuscleConstants.calculateDecayFactor(bodyPartIds.length);
    return totalWeight * decayFactor;
  }

  /// Level 2: Structured data (has set count)
  /// TP = setCount * 1.2
  double calculateLevel2(int setCount) {
    return setCount * level2Multiplier;
  }

  /// Level 3: Complete data (weight, reps, sets)
  /// TP = sum(weight * reps) * difficulty * 1.5
  double calculateLevel3(List<SetRecord> sets, String exerciseName) {
    if (sets.isEmpty) return 0;

    double volume = 0;
    for (final set in sets) {
      volume += set.weight * set.reps;
    }

    final difficulty = MuscleConstants.getExerciseDifficulty(exerciseName);
    return volume * difficulty * level3Multiplier;
  }

  /// Calculate training points for a single set
  double calculateSetTP(SetRecord set, String exerciseName) {
    // Determine which level to use based on data completeness
    if (set.weight == 0 && set.reps == 0) {
      // Level 2: Has set but no weight/reps
      return level2Multiplier;
    } else {
      // Level 3: Complete data
      final volume = set.weight * set.reps;
      final difficulty = MuscleConstants.getExerciseDifficulty(exerciseName);
      return volume * difficulty * level3Multiplier;
    }
  }

  /// Calculate training points for an exercise record
  Future<double> calculateExerciseRecordTP(ExerciseRecord record) async {
    final sets = await _db.getSetsByExerciseRecord(record.id);
    
    // Handle null exerciseId (body part only records)
    if (record.exerciseId == null) {
      return calculateLevel1([]);
    }
    
    final exercise = await _db.getExerciseById(record.exerciseId!);

    if (sets.isEmpty) {
      // Level 1: Only body part
      // Parse bodyPartIds from exercise
      final bodyPartIds = exercise != null ? _parseBodyPartIds(exercise.bodyPartIds) : <String>[];
      return calculateLevel1(bodyPartIds);
    }

    // Calculate based on each set's data
    double totalTP = 0;
    for (final set in sets) {
      totalTP += calculateSetTP(set, exercise?.name ?? '');
    }

    return totalTP;
  }

  /// Calculate training points for a session
  Future<double> calculateSessionTP(String sessionId) async {
    final records = await _db.getRecordsBySession(sessionId);
    double totalTP = 0;

    for (final record in records) {
      totalTP += await calculateExerciseRecordTP(record);
    }

    return totalTP;
  }

  /// Calculate training points for all sessions and return as date-indexed map
  Future<Map<DateTime, double>> calculateAllSessionTP() async {
    final sessions = await _db.getAllSessions();
    final Map<DateTime, double> index = {};

    for (final session in sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      final tp = await calculateSessionTP(session.id);
      index[date] = tp;
    }

    return index;
  }

  /// Get the maximum TP value for normalization
  Future<double> getMaxTP() async {
    final tpMap = await calculateAllSessionTP();
    if (tpMap.isEmpty) return 100.0; // Default fallback
    return tpMap.values.reduce((a, b) => a > b ? a : b);
  }

  /// Get normalized TP value (0.0 - 1.0)
  double normalizeTP(double tp, double maxTP) {
    if (maxTP == 0) return 0;
    return (tp / maxTP).clamp(0.0, 1.0);
  }

  /// Determine confidence level for a session
  Future<DataConfidenceLevel> getSessionConfidenceLevel(String sessionId) async {
    final records = await _db.getRecordsBySession(sessionId);

    bool hasComplete = false;
    bool hasPartial = false;

    for (final record in records) {
      final sets = await _db.getSetsByExerciseRecord(record.id);

      if (sets.isEmpty) {
        // Body part only - lowest priority
      } else if (sets.every((s) => s.weight == 0 && s.reps == 0)) {
        hasPartial = true;
      } else {
        hasComplete = true;
      }
    }

    // Priority: Complete > Partial > BodyPartOnly
    if (hasComplete) return DataConfidenceLevel.level3_Complete;
    if (hasPartial) return DataConfidenceLevel.level2_SetCountOnly;
    return DataConfidenceLevel.level1_BodyPartOnly;
  }
}
