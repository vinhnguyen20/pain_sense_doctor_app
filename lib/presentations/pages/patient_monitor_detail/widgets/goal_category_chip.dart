import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:flutter/material.dart';

class GoalCategoryChips extends StatelessWidget {
  final GoalCategory selected;
  final bool readOnly;
  final ValueChanged<GoalCategory> onChanged;

  const GoalCategoryChips({
    super.key,
    required this.selected,
    required this.readOnly,
    required this.onChanged,
  });

  static const _items = [
    (GoalCategory.steps, Icons.directions_walk_rounded, 'Steps/Walking'),
    (GoalCategory.yoga, Icons.self_improvement_rounded, 'Yoga/Meditation'),
    (GoalCategory.activityTime, Icons.timer_outlined, 'Activity Walk'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _items.map((item) {
        final (cat, icon, label) = item;
        final isSelected = selected == cat;

        return GestureDetector(
          onTap: readOnly ? null : () => onChanged(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppPalette.primaryBlue.withValues(alpha: 0.12)
                  : context.commonColors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppPalette.primaryBlue
                    : cs.outline.withValues(alpha: 0.6),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected
                      ? AppPalette.primaryBlue
                      : cs.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? AppPalette.primaryBlue
                        : cs.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class GoalCategoryMultiChips extends StatelessWidget {
  final Map<GoalCategory, bool> selected;
  final bool readOnly;
  final ValueChanged<GoalCategory> onToggle;

  const GoalCategoryMultiChips({
    super.key,
    required this.selected,
    required this.readOnly,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.s8,
      runSpacing: AppSpacing.s8,
      children: GoalCategoryChips._items.map((item) {
        final (cat, icon, label) = item;
        final isSelected = selected[cat] ?? false;

        return GestureDetector(
          onTap: readOnly ? null : () => onToggle(cat),
          child: AnimatedContainer(
            duration: AppDuration.fast,
            padding: AppInsets.chip,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppPalette.primaryBlue.withValues(alpha: 0.12)
                  : context.commonColors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: isSelected
                    ? AppPalette.primaryBlue
                    : cs.outline.withValues(alpha: 0.6),
                width: isSelected ? AppBorder.strong : AppBorder.regular,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: AppSize.iconSm,
                  color: isSelected
                      ? AppPalette.primaryBlue
                      : cs.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: AppSpacing.s6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppPalette.primaryBlue
                        : cs.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: AppSpacing.s6),
                  Icon(
                    Icons.check_circle_rounded,
                    size: AppSize.iconSm,
                    color: AppPalette.primaryBlue,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
