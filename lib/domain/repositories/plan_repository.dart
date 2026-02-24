import '../../data/database/database.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/enums/muscle_enum.dart';

/// Repository for Plan-related database operations
/// This follows Clean Architecture by isolating database operations from the UI layer
class PlanRepository {
  final AppDatabase _db;

  PlanRepository(this._db);

  // ===== TrainingPlan operations =====

  Future<List<TrainingPlan>> getAllPlans() => _db.getAllPlans();

  Future<TrainingPlan?> getPlanById(String id) => _db.getPlanById(id);

  Future<void> insertPlan(TrainingPlansCompanion plan) => _db.insertPlan(plan);

  Future<int> updatePlan(TrainingPlansCompanion plan) => _db.updatePlan(plan);

  Future<int> deletePlan(String id) => _db.deletePlan(id);

  Future<bool> isPlanNameExists(String name) => _db.isPlanNameExists(name);

  // ===== Active Plan operations =====

  /// Get the currently active (executing) plan
  Future<TrainingPlan?> getActivePlan() => _db.getActivePlan();

  /// Set a plan as active (starts execution)
  /// This will deactivate any other active plans first
  Future<void> setActivePlan(String planId, int currentDayIndex) =>
      _db.setActivePlan(planId, currentDayIndex);

  /// Deactivate the current active plan (stop execution)
  Future<void> clearActivePlan() => _db.clearActivePlan();

  /// Update the current day index of the active plan
  Future<void> updateActivePlanDayIndex(int dayIndex) =>
      _db.updateActivePlanDayIndex(dayIndex);

  // ===== PlanItem operations =====

  Future<List<PlanItem>> getPlanItemsByPlan(String planId) =>
      _db.getPlanItemsByPlan(planId);

  Future<void> insertPlanItem(PlanItemsCompanion item) => _db.insertPlanItem(item);

  Future<bool> updatePlanItem(PlanItemsCompanion item) =>
      _db.updatePlanItem(item);

  Future<int> deletePlanItem(String id) => _db.deletePlanItem(id);

  Future<int> deletePlanItemsByPlan(String planId) =>
      _db.deletePlanItemsByPlan(planId);

  // ===== Last Executed Time operations =====

  /// Update the last executed time for a plan
  Future<void> updatePlanLastExecuted(String planId) =>
      _db.updatePlanLastExecuted(planId);

  // ===== Preset Plan Initialization =====

  /// Initialize preset plans into database if they don't exist
  /// This allows preset plans to be edited like custom plans
  Future<void> initializePresetPlans() async {
    final existingPlans = await getAllPlans();
    
    // Check if we already have plans in the database
    if (existingPlans.isNotEmpty) return;
    
    // Import preset plans into database
    for (final templateName in WorkoutTemplates.templateNames) {
      final schedule = WorkoutTemplates.getSchedule(templateName);
      if (schedule == null) continue;
      
      final planId = 'preset_${templateName.hashCode}';
      
      await insertPlan(TrainingPlansCompanion.insert(
        id: planId,
        name: templateName,
        cycleLengthDays: schedule.length,
        createdAt: DateTime.now().toUtc(),
      ));
      
      // Import each day's plan items
      for (final entry in schedule.entries) {
        final muscleGroups = entry.value;
        if (muscleGroups.contains(MuscleGroup.rest)) continue;
        
        // Get body part IDs for each muscle group
        final bodyPartIds = <String>[];
        
        // Query body parts from database
        final allBodyParts = await _db.getAllBodyParts();
        
        for (final mg in muscleGroups) {
          if (mg == MuscleGroup.rest) continue;
          // Find body part ID by muscle group name
          final bodyPart = allBodyParts.where((bp) => 
            bp.name.toLowerCase() == mg.englishName.toLowerCase()
          ).firstOrNull;
          if (bodyPart != null) {
            bodyPartIds.add(bodyPart.id);
          }
        }
        
        if (bodyPartIds.isNotEmpty) {
          await insertPlanItem(PlanItemsCompanion.insert(
            id: '${planId}_${entry.key}',
            planId: planId,
            dayIndex: entry.key - 1,
            bodyPartIds: bodyPartIds.join(','),
          ));
        }
      }
    }
  }
}
