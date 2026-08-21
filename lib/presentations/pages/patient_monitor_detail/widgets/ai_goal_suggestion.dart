import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_action_button.dart';
import 'package:flutter/material.dart';

class AiSuggestionsSection extends StatelessWidget {
  final List<AiGoalSuggestionRow> suggestions;

  const AiSuggestionsSection({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 20,
                color: AppPalette.secondaryBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Suggestions',
                style: AppTypography.titleBig2.copyWith(
                  color: AppPalette.secondaryBlue,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (suggestions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppPalette.surfaceLight,
                borderRadius: AppCorners.r8,
              ),
              child: Text(
                'No AI suggestions available.',
                style: AppTypography.defaultBody2.copyWith(
                  color: AppPalette.secondaryBlue,
                ),
              ),
            )
          else
            ...List.generate(
              suggestions.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == suggestions.length - 1 ? 0 : 10,
                ),
                child: suggestions[index],
              ),
            ),
        ],
      ),
    );
  }
}

class AiGoalSuggestionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String reason;
  final VoidCallback onAdopt;

  const AiGoalSuggestionRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.reason,
    required this.onAdopt,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isCompactShell) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: const BoxDecoration(
          color: AppPalette.surfaceLight,
          borderRadius: AppCorners.r8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: AppCorners.r8,
                  ),
                  child: Icon(icon, size: 22, color: iconColor),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.titleSmall1.copyWith(
                      color: AppPalette.secondaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s10),
            Text(
              description,
              style: AppTypography.denseBody1.copyWith(
                color: AppPalette.black.withValues(alpha: 0.68),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppPalette.warning,
                ),
                const SizedBox(width: AppSpacing.s4),
                Expanded(
                  child: Text(
                    reason,
                    style: AppTypography.captionBody1.copyWith(
                      color: AppPalette.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s14),
            GoalActionButton(
              label: 'Adopt',
              width: double.infinity,
              onPressed: onAdopt,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppPalette.surfaceLight,
        borderRadius: AppCorners.r8,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: AppCorners.r8,
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall1.copyWith(
                    color: AppPalette.secondaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.denseBody1.copyWith(
                    color: AppPalette.black.withValues(alpha: 0.68),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: AppPalette.warning,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        reason,
                        style: AppTypography.captionBody1.copyWith(
                          color: AppPalette.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          GoalActionButton(label: 'Adopt', width: 137, onPressed: onAdopt),
        ],
      ),
    );
  }
}
