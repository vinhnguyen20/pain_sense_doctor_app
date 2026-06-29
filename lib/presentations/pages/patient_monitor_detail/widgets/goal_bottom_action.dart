import 'package:app_doctor/common/widgets/app_button.dart';
import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:flutter/material.dart';

class GoalBottomActions extends StatelessWidget {
  final GoalFormMode mode;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final VoidCallback onEdit;
  final bool isSubmitting;

  const GoalBottomActions({
    super.key,
    required this.mode,
    required this.onSubmit,
    required this.onCancel,
    required this.onEdit,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return mode == GoalFormMode.view
        ? _ViewActions(onCancel: onCancel, onEdit: onEdit)
        : _MutateActions(
            mode: mode,
            onSubmit: onSubmit,
            onCancel: onCancel,
            isSubmitting: isSubmitting,
          );
  }
}

class _ViewActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onEdit;

  const _ViewActions({required this.onCancel, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            onPressed: onCancel,
            label: 'Back',
            icon: Icons.arrow_back_rounded,
            variant: AppButtonVariant.outline,
            size: AppButtonScale.medium,
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: AppButton(
            onPressed: onEdit,
            label: 'Edit Goal',
            icon: Icons.edit_outlined,
            size: AppButtonScale.medium,
          ),
        ),
      ],
    );
  }
}

class _MutateActions extends StatelessWidget {
  final GoalFormMode mode;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final bool isSubmitting;

  const _MutateActions({
    required this.mode,
    required this.onSubmit,
    required this.onCancel,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    final isCreate = mode == GoalFormMode.create;

    return Row(
      children: [
        Expanded(
          child: AppButton(
            onPressed: isSubmitting ? null : onCancel,
            label: 'Cancel',
            variant: AppButtonVariant.outline,
            size: AppButtonScale.medium,
          ),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          flex: 2,
          child: AppButton(
            onPressed: isSubmitting ? null : onSubmit,
            isLoading: isSubmitting,
            label: isCreate ? 'Create Goal' : 'Save Changes',
            icon: isCreate
                ? Icons.check_circle_outline_rounded
                : Icons.save_outlined,
            size: AppButtonScale.medium,
          ),
        ),
      ],
    );
  }
}
