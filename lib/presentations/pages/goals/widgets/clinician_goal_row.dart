import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_action_button.dart';
import 'package:flutter/material.dart';

class ClinicianGoalRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onAssign;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClinicianGoalRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onAssign,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppPalette.surfaceLight,
        borderRadius: AppCorners.r8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Center(
                    child: Icon(
                      icon,
                      size: 28,
                      color: AppPalette.secondaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.defaultBody1.copyWith(
                      color: AppPalette.secondaryBlue,
                      height: 1.18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 354,
            height: 50,
            child: Row(
              children: [
                GoalActionButton(
                  label: 'Assign',
                  width: 137,
                  onPressed: onAssign,
                ),
                const SizedBox(width: 20),
                GoalActionButton(
                  label: 'Edit',
                  width: 137,
                  onPressed: onEdit,
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 40,
                  height: 50,
                  child: IconButton(
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 36,
                      color: AppPalette.secondaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
