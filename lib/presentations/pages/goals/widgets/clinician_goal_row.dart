import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_action_button.dart';
import 'package:flutter/material.dart';

/// A single top-level goal in the goals list.
///
/// The row intentionally does not expand in place. Tapping the row opens the
/// goal detail screen, where all of its goal items are listed.
class ClinicianGoalRow extends StatelessWidget {
  final UserGoalModel goal;
  final VoidCallback? onOpen;
  final VoidCallback onAssign;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClinicianGoalRow({
    super.key,
    required this.goal,
    this.onOpen,
    required this.onAssign,
    required this.onEdit,
    required this.onDelete,
  });

  String _title() {
    final item = goal.goalItems.firstOrNull;
    if (item == null) return 'Goal';
    final label = item.label.trim();
    if (label.isNotEmpty) return label;
    final target = '${item.minTarget} ${item.unit}'.trim();
    return target.isEmpty ? item.type.displayName : target;
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = goal.goalItems.firstOrNull;
    final itemCount = goal.goalItems.length;
    final title = _title();

    return Material(
      color: AppPalette.surfaceLight,
      borderRadius: AppCorners.r8,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s10,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final titleWidget = Row(
                children: [
                  Icon(
                    firstItem?.type.icon ?? Icons.flag_outlined,
                    size: 28,
                    color: AppPalette.secondaryBlue,
                  ),
                  const SizedBox(width: AppSpacing.s14),
                  Expanded(
                    child: Text(
                      itemCount > 1 ? '$title (+${itemCount - 1})' : title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall1.copyWith(
                        color: AppPalette.secondaryBlue,
                      ),
                    ),
                  ),
                ],
              );
              final actions = Wrap(
                alignment: WrapAlignment.end,
                spacing: AppSpacing.s10,
                runSpacing: AppSpacing.s10,
                children: [
                  GoalActionButton(
                    label: 'Assign',
                    width: 137,
                    onPressed: onAssign,
                  ),
                  GoalActionButton(
                    label: 'Edit',
                    width: 137,
                    onPressed: onEdit,
                  ),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: IconButton(
                      tooltip: 'Delete Goal',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: AppPalette.secondaryBlue,
                      iconSize: 31,
                    ),
                  ),
                ],
              );

              if (constraints.maxWidth < 760) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleWidget,
                    const SizedBox(height: AppSpacing.s10),
                    actions,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleWidget),
                  const SizedBox(width: AppSpacing.s12),
                  actions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
