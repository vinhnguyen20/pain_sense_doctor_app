import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/domain/entites/user_goal_request.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserGoalCard extends ConsumerStatefulWidget {
  final UserGoalModel goal;
  final String patientId;
  final VoidCallback onDelete;

  const UserGoalCard({
    super.key,
    required this.goal,
    required this.patientId,
    required this.onDelete,
  });

  @override
  ConsumerState<UserGoalCard> createState() => _UserGoalCardState();
}

class _UserGoalCardState extends ConsumerState<UserGoalCard> {
  bool _expanded = false;

  String _formatDate(DateTime dt) => DateUtilsHelper.formatDateDMY(dt);

  Color _colorForType(BuildContext context, GoalType type) => switch (type) {
    GoalType.stepsWalking => context.goalColors.iconWalking,
    GoalType.yogaMeditation => context.goalColors.iconYoga,
    GoalType.activityWalk => context.goalColors.iconWalking,
    GoalType.unknown => context.primary,
  };

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: context.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await ref
        .read(deleteUserGoalUseCaseProvider)
        .call(widget.goal.id);

    if (response.isSuccess) {
      widget.onDelete();
    } else {
      if (context.mounted) {
        AppSnackbar.error(context, response.message);
      }
    }
  }

  Future<void> _openEditMode() async {
    final result = await context.pushNamed(
      'goal-form',
      extra: {
        'mode': GoalFormMode.edit,
        'initialGoal': widget.goal.toGoalModel(),
        'originalGoalItems': widget.goal.goalItems,
        'patientId': widget.patientId,
      },
    );
    if (result != null) {
      if (result is UpdateUserGoalRequest) {
        ref
            .read(patientUserGoalsProvider(widget.patientId).notifier)
            .applyUpdate(result);
      } else {
        widget.onDelete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final firstItem = goal.goalItems.isNotEmpty ? goal.goalItems.first : null;
    final icon = firstItem?.type.icon ?? Icons.flag_outlined;
    final iconColor = firstItem != null
        ? _colorForType(context, firstItem.type)
        : context.primary;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: AppCorners.r12,
        border: Border.all(color: context.border),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: AppCorners.r10,
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatDate(goal.startDate)} → ${_formatDate(goal.endDate)}',
                          style: context.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${goal.goalItems.length} goal item${goal.goalItems.length > 1 ? 's' : ''}',
                          style: context.bodySmall?.copyWith(
                            color: context.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: context.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            Divider(color: context.border, height: 1, thickness: 0.8),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...goal.goalItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                      child: _GoalItemRow(item: item),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Divider(color: context.border, height: 1, thickness: 0.8),
                  const SizedBox(height: AppSpacing.s8),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Created',
                    value: _formatDate(goal.createdAt),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openEditMode,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Goal'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _confirmDelete,
                          icon: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: context.error,
                          ),
                          label: Text(
                            'Delete',
                            style: TextStyle(color: context.error),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GoalItemRow extends StatelessWidget {
  final GoalItemModel item;

  const _GoalItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 16,
          color: context.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.type.displayName,
                style: context.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.desc} · ${item.minTarget} ${item.unit}',
                style: context.bodySmall?.copyWith(
                  color: context.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: context.onSurface.withValues(alpha: 0.4)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: context.labelSmall?.copyWith(
            color: context.onSurface.withValues(alpha: 0.45),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.labelSmall?.copyWith(
              color: context.onSurface.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
