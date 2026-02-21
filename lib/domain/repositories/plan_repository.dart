import '../../data/database/database.dart';

/// Repository for Plan-related database operations
/// This follows Clean Architecture by isolating database operations from the UI layer
class PlanRepository {
  final AppDatabase _db;

  PlanRepository(this._db);

  // ===== TrainingPlan operations =====

  Future<List<TrainingPlan>> getAllPlans() => _db.getAllPlans();

  Future<TrainingPlan?> getPlanById(String id) => _db.getPlanById(id);

  Future<void> insertPlan(TrainingPlansCompanion plan) => _db.insertPlan(plan);

  Future<bool> updatePlan(TrainingPlansCompanion plan) => _db.updatePlan(plan);

  Future<int> deletePlan(String id) => _db.deletePlan(id);

  // ===== PlanItem operations =====

  Future<List<PlanItem>> getPlanItemsByPlan(String planId) =>
      _db.getPlanItemsByPlan(planId);

  Future<void> insertPlanItem(PlanItemsCompanion item) => _db.insertPlanItem(item);

  Future<bool> updatePlanItem(PlanItemsCompanion item) =>
      _db.updatePlanItem(item);

  Future<int> deletePlanItem(String id) => _db.deletePlanItem(id);

  Future<int> deletePlanItemsByPlan(String planId) =>
      _db.deletePlanItemsByPlan(planId);
}
