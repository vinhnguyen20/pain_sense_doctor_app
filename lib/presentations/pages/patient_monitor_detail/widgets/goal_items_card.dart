import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_shared_widget.dart';
import 'package:flutter/material.dart';

class GoalItemsCard extends StatelessWidget {
  final List<GoalCategory> selectedCategories;
  final Map<GoalCategory, TextEditingController> titleCtrls;
  final Map<GoalCategory, TextEditingController> targetCtrls;
  final Map<GoalCategory, TextEditingController> descCtrls;
  final int computedYogaTarget;
  final bool readOnly;

  const GoalItemsCard({
    super.key,
    required this.selectedCategories,
    required this.titleCtrls,
    required this.targetCtrls,
    required this.descCtrls,
    required this.computedYogaTarget,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      children: [
        const SectionLabel(label: 'Goal Details'),
        const SizedBox(height: AppSpacing.s8),
        Text(
          'Fill details for each selected goal type. Each goal item has independent content.',
          style: context.bodySmall?.copyWith(
            color: context.onSurface.withValues(alpha: 0.65),
          ),
        ),
        if (selectedCategories.isEmpty) ...[
          const SizedBox(height: AppSpacing.s10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s10),
            decoration: BoxDecoration(
              color: context.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.r8),
              border: Border.all(
                color: context.warning.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              'Please select at least one goal type above.',
              style: context.bodySmall?.copyWith(
                color: context.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
        for (final category in selectedCategories) ...[
          const SizedBox(height: AppSpacing.s12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(AppRadius.r10),
              border: Border.all(color: context.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(category.icon, size: 18, color: context.primary),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        category.label,
                        style: context.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s10),
                GoalFormTextField(
                  label: 'Title',
                  controller: titleCtrls[category]!,
                  hint: 'e.g. ${category.label}',
                  readOnly: readOnly,
                ),
                const SizedBox(height: AppSpacing.s10),
                if (category != GoalCategory.yoga) ...[
                  GoalFormTextField(
                    label: category.targetLabel,
                    numbersOnly: true,
                    controller: targetCtrls[category]!,
                    hint: category.targetHint,
                    readOnly: readOnly,
                  ),
                ],
                const SizedBox(height: AppSpacing.s10),
                GoalFormTextField(
                  label: 'Description',
                  controller: descCtrls[category]!,
                  hint: 'Describe why this goal is important...',
                  maxLines: 3,
                  readOnly: readOnly,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
