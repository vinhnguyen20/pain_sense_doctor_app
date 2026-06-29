import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/core/utils/date_utils_helper.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_activity.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';
import 'package:flutter/material.dart';

class PatientDiaryGroup {
  static List<Widget> buildSliverItems(
    BuildContext context,
    List<PatientDiaryEntry> entries,
  ) {
    final List<Widget> items = [];

    for (final entry in entries) {
      items.add(_DateHeader(date: entry.date));

      for (final activity in entry.diary) {
        items.add(
          Padding(
            key: ValueKey('${entry.id}_${activity.label}'),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PatientActivityCard(activity: activity),
          ),
        );
      }
    }

    return items;
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;

  const _DateHeader({required this.date});

  String _formatDate(DateTime date) =>
      DateUtilsHelper.formatRelativeDate(date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        _formatDate(date),
        style: context.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.onSurface.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

class PatientActivityCard extends StatelessWidget {
  final PatientDiaryActivity activity;
  final VoidCallback? onTap;

  const PatientActivityCard({super.key, required this.activity, this.onTap});

  IconData _iconForType(GoalType type) => switch (type) {
    GoalType.stepsWalking => Icons.directions_walk_outlined,
    GoalType.yogaMeditation => Icons.self_improvement_outlined,
    GoalType.activityWalk => Icons.directions_run_outlined,
    GoalType.unknown => Icons.fitness_center_outlined,
  };

  Color _progressColor(double percent) {
    if (percent >= 100) return Colors.green;
    if (percent >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final percent = activity.percent;
    final progress = (percent / 100).clamp(0.0, 1.0);
    final color = _progressColor(percent);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _iconForType(activity.type),
                                  size: 13,
                                  color: context.onSurface.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  activity.type.displayName,
                                  style: context.bodySmall?.copyWith(
                                    color: context.onSurface.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity.label,
                              style: context.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activity.desc,
                              style: context.bodySmall?.copyWith(
                                color: context.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity.display,
                              style: context.bodySmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      SizedBox(
                        width: 52,
                        height: 52,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 5,
                                backgroundColor: context.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  color,
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Text(
                              '${percent.toStringAsFixed(0)}%',
                              style: context.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
