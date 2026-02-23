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
  final bool isHighlighted;

  const CustomPlanDayItem({
    super.key,
    required this.planItem,
    required this.isDark,
    required this.l10n,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyPartIds = planItem.bodyPartIds.split(',').where((s) => s.isNotEmpty).toList();
    final bodyPartsAsync = ref.watch(bodyPartsProvider);
    final locale = Localizations.localeOf(context).languageCode;

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
              'Day ${planItem.dayIndex + 1}',
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
            child: bodyPartsAsync.when(
              data: (bodyParts) {
                final displayItems = bodyParts
                    .where((bp) => bodyPartIds.contains(bp.id))
                    .map((bp) {
                      final muscleGroup = MuscleGroupHelper.getMuscleGroupByName(bp.name);
                      return {
                        'name': muscleGroup != null ? muscleGroup.getLocalizedName(locale) : bp.name,
                        'color': muscleGroup != null 
                            ? AppTheme.getMuscleColor(muscleGroup) 
                            : MuscleGroupHelper.getColorForBodyPart(bp.name),
                      };
                    })
                    .toList();

                if (displayItems.isEmpty) {
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
                  children: displayItems.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        item['name'] as String,
                        style: TextStyle(
                          color: item['color'] as Color,
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
