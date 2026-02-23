import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/enums/muscle_enum.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../data/database/database.dart';
import '../../providers/providers.dart';
import 'custom_plan_day_item.dart';
import '../muscle_group_helper.dart';

class PlanDetailsWidget extends ConsumerWidget {
  final String planName;
  final bool isDark;
  final AppLocalizations l10n;

  const PlanDetailsWidget({
    super.key,
    required this.planName,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = WorkoutTemplates.getSchedule(planName);

    if (schedule != null) {
      return _buildPresetPlan(context, ref, schedule);
    }

    return _buildCustomPlan(context, ref);
  }

  Widget _buildPresetPlan(BuildContext context, WidgetRef ref, Map<int, List<MuscleGroup>> schedule) {
    final locale = Localizations.localeOf(context).languageCode;

    // Get active preset plan for highlighting
    final activePresetPlan = ref.watch(activePresetPlanProvider);
    final activePresetDay = ref.watch(activePresetDayIndexProvider);
    final isThisPresetActive = activePresetPlan == planName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$planName ${l10n.schedule}',
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...schedule.entries.map((entry) => _buildScheduleRow(
            context,
            entry.key,
            entry.value,
            isHighlighted: isThisPresetActive && entry.key == activePresetDay,
          )),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(BuildContext context, int dayOfWeek, List<MuscleGroup> muscles, {bool isHighlighted = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Highlighted: border + background
        color: isHighlighted ? AppTheme.accent.withOpacity(0.08) : null,
        border: isHighlighted
            ? Border.all(color: AppTheme.accent, width: 2)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              _getDayName(dayOfWeek),
              style: TextStyle(
                color: isHighlighted
                    ? AppTheme.accent
                    : isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: muscles.map((muscle) => _buildMuscleChip(context, muscle)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleChip(BuildContext context, MuscleGroup muscle) {
    final color = AppTheme.getMuscleColor(muscle);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getMuscleName(context, muscle),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCustomPlan(BuildContext context, WidgetRef ref) {
    final customPlan = ref.watch(customPlanByNameProvider(planName));
    if (customPlan == null) return const SizedBox.shrink();
    
    final itemsAsync = ref.watch(planItemsProvider(customPlan.id));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$planName ${l10n.schedule}',
                style: TextStyle(
                  color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${customPlan.cycleLengthDays} ${l10n.days}',
                style: TextStyle(
                  color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          itemsAsync.when(
            data: (items) => _buildItemsList(context, ref, items, customPlan.id, customPlan.cycleLengthDays),
            loading: () => const CircularProgressIndicator(),
            error: (e, s) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, WidgetRef ref, List<PlanItem> items, String planId, int cycleLengthDays) {
    // Create a map for quick lookup of existing items
    final itemsMap = {for (var item in items) item.dayIndex: item};

    // Get active plan info for highlighting
    final activePlanAsync = ref.watch(activePlanProvider);
    final activePlanName = activePlanAsync.when(
      data: (plan) => plan?.name,
      loading: () => null,
      error: (_, __) => null,
    );
    final currentDay = activePlanAsync.when(
      data: (plan) => plan?.currentDayIndex ?? 1,
      loading: () => 1,
      error: (_, __) => 1,
    );

    // Check if this plan is active and should show highlighting
    final isThisPlanActive = activePlanName == planName;

    return Column(
      children: [
        // Generate rows for all days in the cycle
        for (int dayIndex = 0; dayIndex < cycleLengthDays; dayIndex++)
          if (itemsMap.containsKey(dayIndex))
            CustomPlanDayItem(
              planItem: itemsMap[dayIndex]!,
              isDark: isDark,
              l10n: l10n,
              isHighlighted: isThisPlanActive && (dayIndex + 1) == currentDay,
            )
          else
            // Rest day - show day without any body parts
            _buildRestDayRow(dayIndex, isHighlighted: isThisPlanActive && (dayIndex + 1) == currentDay),
      ],
    );
  }

  Widget _buildRestDayRow(int dayIndex, {bool isHighlighted = false}) {
    // Get the gray color for rest
    final restColor = AppTheme.getMuscleColor(MuscleGroup.rest);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Highlighted: border + background
        color: isHighlighted ? AppTheme.accent.withOpacity(0.08) : null,
        border: isHighlighted
            ? Border.all(color: AppTheme.accent, width: 2)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              'Day ${dayIndex + 1}',
              style: TextStyle(
                color: isHighlighted
                    ? AppTheme.accent
                    : isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          // Use Wrap like other muscle chips to avoid expanding
          Wrap(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: restColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l10n.rest,
                  style: TextStyle(
                    color: restColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddPlanItemDialog(BuildContext context, WidgetRef ref, String planId, int cycleLengthDays) {
    int selectedDayIndex = 0;
    final bodyPartsAsync = ref.read(bodyPartsProvider);
    List<String> selectedBodyPartIds = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addTrainingDay),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n.selectDay} (1-$cycleLengthDays):'),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: selectedDayIndex > 0 ? () => setState(() => selectedDayIndex--) : null,
                  ),
                  Text('Day ${selectedDayIndex + 1}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: selectedDayIndex < cycleLengthDays - 1 ? () => setState(() => selectedDayIndex++) : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.selectBodyParts),
              const SizedBox(height: 8),
              bodyPartsAsync.when(
                data: (bodyParts) {
                  final locale = Localizations.localeOf(context).languageCode;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: bodyParts.map((bp) {
                      final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bp.name);
                      final displayName = muscleGroup != null 
                          ? muscleGroup.getLocalizedName(locale) 
                          : bp.name;
                      return FilterChip(
                        label: Text(displayName),
                        selected: selectedBodyPartIds.contains(bp.id),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) selectedBodyPartIds.add(bp.id);
                            else selectedBodyPartIds.remove(bp.id);
                          });
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: selectedBodyPartIds.isNotEmpty ? () async {
                final repo = ref.read(planRepositoryProvider);
                await repo.insertPlanItem(PlanItemsCompanion.insert(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  planId: planId,
                  dayIndex: selectedDayIndex,
                  bodyPartIds: selectedBodyPartIds.join(','),
                ));
                ref.invalidate(planItemsProvider(planId));
                if (context.mounted) Navigator.pop(context);
              } : null,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
  }

  String _getMuscleName(BuildContext context, MuscleGroup muscle) {
    if (muscle == MuscleGroup.rest) return l10n.rest;
    final locale = Localizations.localeOf(context).languageCode;
    return muscle.getLocalizedName(locale);
  }
}
