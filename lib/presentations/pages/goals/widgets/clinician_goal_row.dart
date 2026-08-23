import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_action_button.dart';
import 'package:flutter/material.dart';

class ClinicianGoalRow extends StatefulWidget {
  final UserGoalModel goal;
  final VoidCallback onAssign;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClinicianGoalRow({
    super.key,
    required this.goal,
    required this.onAssign,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ClinicianGoalRow> createState() => _ClinicianGoalRowState();
}

class _ClinicianGoalRowState extends State<ClinicianGoalRow> {
  bool _expanded = false;

  String _formatDate(DateTime value) => DateUtilsHelper.formatDateDMY(value);

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final itemCount = goal.goalItems.length;
    final firstItem = goal.goalItems.firstOrNull;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: AppCorners.r12,
        border: Border.all(color: AppLightColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: AppPalette.surfaceLight,
                      borderRadius: AppCorners.r12,
                    ),
                    child: Icon(
                      firstItem?.type.icon ?? Icons.flag_outlined,
                      size: 26,
                      color: AppPalette.secondaryBlue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goal · ${_formatDate(goal.startDate)} – ${_formatDate(goal.endDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleBig1.copyWith(
                            color: AppPalette.secondaryBlue,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          '$itemCount goal item${itemCount == 1 ? '' : 's'}',
                          style: AppTypography.denseBody1.copyWith(
                            color: AppPalette.black.withValues(alpha: 0.58),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppPalette.secondaryBlue,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _ExpandedGoalContent(
              goalItems: goal.goalItems,
              onAssign: widget.onAssign,
              onEdit: widget.onEdit,
              onDelete: widget.onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedGoalContent extends StatelessWidget {
  final List<GoalItemModel> goalItems;
  final VoidCallback onAssign;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpandedGoalContent({
    required this.goalItems,
    required this.onAssign,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: const BoxDecoration(
        color: AppPalette.surfaceLight,
        border: Border(top: BorderSide(color: AppLightColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < goalItems.length; index++) ...[
            _GoalItemDetail(item: goalItems[index]),
            if (index != goalItems.length - 1)
              const SizedBox(height: AppSpacing.s10),
          ],
          const SizedBox(height: AppSpacing.s14),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.s10,
            runSpacing: AppSpacing.s10,
            children: [
              GoalActionButton(
                label: 'Assign',
                width: 137,
                onPressed: onAssign,
              ),
              GoalActionButton(label: 'Edit', width: 137, onPressed: onEdit),
              SizedBox(
                width: 50,
                height: 50,
                child: IconButton.outlined(
                  tooltip: 'Delete Goal',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppPalette.secondaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalItemDetail extends StatelessWidget {
  final GoalItemModel item;

  const _GoalItemDetail({required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item.label.trim().isEmpty
        ? item.type.displayName
        : item.label.trim();
    final description = item.desc.trim();
    final exerciseCount = item.userExercises?.length ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: const BoxDecoration(
        color: AppPalette.white,
        borderRadius: AppCorners.r12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.type.icon, color: AppPalette.secondaryBlue, size: 24),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall1.copyWith(
                    color: AppPalette.secondaryBlue,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  item.type.displayName,
                  style: AppTypography.denseBody1.copyWith(
                    color: AppPalette.black.withValues(alpha: 0.56),
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s6),
                  Text(description, style: AppTypography.defaultBody2),
                ],
                const SizedBox(height: AppSpacing.s8),
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s6,
                  children: [
                    _DetailChip(
                      icon: Icons.track_changes_rounded,
                      label: '${item.minTarget} ${item.unit}',
                    ),
                    if (exerciseCount > 0)
                      _DetailChip(
                        icon: Icons.fitness_center_rounded,
                        label:
                            '$exerciseCount exercise${exerciseCount == 1 ? '' : 's'}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s6,
      ),
      decoration: const BoxDecoration(
        color: AppPalette.surfaceLight,
        borderRadius: AppCorners.r20,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppPalette.secondaryBlue),
          const SizedBox(width: AppSpacing.s4),
          Text(label, style: AppTypography.denseBody1),
        ],
      ),
    );
  }
}
