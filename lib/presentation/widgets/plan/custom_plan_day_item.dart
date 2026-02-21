import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database/database.dart';
import '../../providers/providers.dart';
import '../muscle_group_helper.dart';

class CustomPlanDayItem extends ConsumerWidget {
  final PlanItem planItem;
  final bool isDark;
  final AppLocalizations l10n;

  const CustomPlanDayItem({
    super.key,
    required this.planItem,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyPartIds = planItem.bodyPartIds.split(',').where((s) => s.isNotEmpty).toList();
    final bodyPartsAsync = ref.watch(bodyPartsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              'Day ${planItem.dayIndex + 1}',
              style: TextStyle(
                color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: bodyPartsAsync.when(
              data: (bodyParts) {
                final names = bodyParts
                    .where((bp) => bodyPartIds.contains(bp.id))
                    .map((bp) => bp.name)
                    .toList();
                
                if (names.isEmpty) {
                  return Text(
                    l10n.rest,
                    style: TextStyle(
                      color: isDark ? AppTheme.textTertiary : AppTheme.textTertiaryLight,
                      fontSize: 12,
                    ),
                  );
                }
                
                return Wrap(
                  spacing: 8,
                  children: names.map((name) {
                    final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(name);
                    final color = AppTheme.getMuscleColor(muscleGroup);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        name,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
