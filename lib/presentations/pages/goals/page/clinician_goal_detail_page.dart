import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/presentation/provider/diary_providers.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/presentations/pages/patient_connect/widgets/patient_connect_header.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_action_button.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClinicianGoalDetailPage extends ConsumerWidget {
  final UserGoalModel goal;
  final Patient patient;
  final bool insidePatientDashboard;

  const ClinicianGoalDetailPage({
    super.key,
    required this.goal,
    required this.patient,
    required this.insidePatientDashboard,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = context.isCompactShell;
    return Scaffold(
      backgroundColor: AppPalette.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = _buildContent(context, ref, compact);
            if (compact) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: content,
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 60,
                ),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PatientConnectHeader(patient: patient),
        SizedBox(height: compact ? AppSpacing.s20 : 30.0),
        Row(
          children: [
            IconButton(
              tooltip: 'Back to goals',
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppPalette.secondaryBlue,
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Text(
                'Assigned Goals',
                style: AppTypography.heading1.copyWith(
                  color: AppPalette.secondaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        Padding(
          padding: const EdgeInsets.only(left: 56),
          child: Text(
            '${DateUtilsHelper.formatDateDMY(goal.startDate)} – ${DateUtilsHelper.formatDateDMY(goal.endDate)}',
            style: AppTypography.defaultBody2.copyWith(
              color: AppPalette.black.withValues(alpha: .58),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s20),
        if (goal.goalItems.isEmpty)
          _EmptyGoalItems()
        else
          ...goal.goalItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s10),
              child: _GoalItemRow(
                item: item,
                onEdit: () => _openEdit(context, ref),
                onDelete: () => _deleteGoal(context, ref),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openEdit(BuildContext context, WidgetRef ref) async {
    final patientId = patient.id.trim();
    if (patientId.isEmpty) {
      AppSnackbar.error(context, 'Patient id is missing. Cannot edit goal.');
      return;
    }

    final result = await context.pushNamed(
      insidePatientDashboard ? 'patient-goal-form' : 'clinician-goal-form',
      extra: {
        'mode': GoalFormMode.edit,
        'initialGoal': goal.toGoalModel(),
        'originalGoalItems': goal.goalItems,
        'patientId': patientId,
      },
    );

    if (!context.mounted) return;
    if (result != null) {
      ref.invalidate(patientUserGoalsProvider(patientId));
    }
  }

  Future<void> _deleteGoal(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final response = await ref
        .read(deleteUserGoalUseCaseProvider)
        .call(goal.id);
    if (!context.mounted) return;

    if (response.isSuccess) {
      ref.invalidate(patientUserGoalsProvider(patient.id));
      context.pop();
    } else {
      AppSnackbar.error(context, response.message);
    }
  }
}

class _GoalItemRow extends StatelessWidget {
  final GoalItemModel item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalItemRow({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = item.label.trim().isEmpty
        ? item.type.displayName
        : item.label.trim();
    final target = '${item.minTarget} ${item.unit}'.trim();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppPalette.surfaceLight,
        borderRadius: AppCorners.r8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final titleWidget = Row(
            children: [
              Icon(item.type.icon, color: AppPalette.secondaryBlue, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall1.copyWith(
                        color: AppPalette.secondaryBlue,
                      ),
                    ),
                    if (target.isNotEmpty)
                      Text(
                        target,
                        style: AppTypography.denseBody1.copyWith(
                          color: AppPalette.black.withValues(alpha: .58),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
          final actions = Wrap(
            alignment: WrapAlignment.end,
            spacing: 10,
            runSpacing: 10,
            children: [
              GoalActionButton(label: 'Edit', width: 137, onPressed: onEdit),
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

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [titleWidget, const SizedBox(height: 10), actions],
            );
          }

          return Row(
            children: [
              Expanded(child: titleWidget),
              const SizedBox(width: 12),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _EmptyGoalItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppPalette.surfaceLight,
        borderRadius: AppCorners.r8,
      ),
      child: Text(
        'No goal details available.',
        style: AppTypography.defaultBody2.copyWith(
          color: AppPalette.secondaryBlue,
        ),
      ),
    );
  }
}
