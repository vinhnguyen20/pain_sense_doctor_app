import 'package:app_doctor/core/config/theme/theme_extension.dart';
import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/education/domain/entites/exercise.dart';
import 'package:flutter/material.dart';

enum GoalCategory {
  steps,
  activityTime,
  yoga;

  static GoalCategory fromGoalType(GoalType type) => switch (type) {
    GoalType.stepsWalking => GoalCategory.steps,
    GoalType.activityWalk => GoalCategory.activityTime,
    GoalType.yogaMeditation => GoalCategory.yoga,
    GoalType.unknown => GoalCategory.steps,
  };

  static GoalCategory? fromRaw(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    return switch (value) {
      'steps' || 'steps/walking' || 'walking' => GoalCategory.steps,
      'activitytime' ||
      'activity_time' ||
      'activity_walk' ||
      'activity' => GoalCategory.activityTime,
      'yoga' || 'yoga/meditation' || 'meditation' => GoalCategory.yoga,
      _ => null,
    };
  }
}

extension GoalCategoryUi on GoalCategory {
  GoalType get goalType => switch (this) {
    GoalCategory.steps => GoalType.stepsWalking,
    GoalCategory.activityTime => GoalType.activityWalk,
    GoalCategory.yoga => GoalType.yogaMeditation,
  };

  String get unit => switch (this) {
    GoalCategory.steps => 'steps',
    GoalCategory.activityTime => 'minutes',
    GoalCategory.yoga => 'exercises',
  };

  String get label => switch (this) {
    GoalCategory.steps => 'Daily Steps',
    GoalCategory.activityTime => 'Walking Time',
    GoalCategory.yoga => 'Yoga',
  };

  IconData get icon => switch (this) {
    GoalCategory.steps => Icons.directions_walk_rounded,
    GoalCategory.activityTime => Icons.timer_outlined,
    GoalCategory.yoga => Icons.self_improvement_rounded,
  };

  String get targetHint => switch (this) {
    GoalCategory.steps => 'e.g. 5000',
    GoalCategory.activityTime => 'e.g. 30',
    GoalCategory.yoga => 'e.g. 3 (number of exercises)',
  };

  String get targetLabel => switch (this) {
    GoalCategory.steps => 'Target (steps)',
    GoalCategory.activityTime => 'Target (minutes)',
    GoalCategory.yoga => 'Target (exercise count)',
  };
}

enum GoalFrequency { daily, weekly, monthly }

enum GoalFormMode { create, edit, view }

class GoalExerciseSlotDraft {
  final String period;
  final String time;
  final String instruction;

  const GoalExerciseSlotDraft({
    this.period = 'morning',
    this.time = '07:00',
    this.instruction = '',
  });

  GoalExerciseSlotDraft copyWith({
    String? period,
    String? time,
    String? instruction,
  }) {
    return GoalExerciseSlotDraft(
      period: period ?? this.period,
      time: time ?? this.time,
      instruction: instruction ?? this.instruction,
    );
  }
}

class GoalExerciseScheduleDraft {
  final DateTime exerciseDate;
  final List<GoalExerciseSlotDraft> slots;

  const GoalExerciseScheduleDraft({
    required this.exerciseDate,
    this.slots = const [GoalExerciseSlotDraft()],
  });

  GoalExerciseScheduleDraft copyWith({
    DateTime? exerciseDate,
    List<GoalExerciseSlotDraft>? slots,
  }) {
    return GoalExerciseScheduleDraft(
      exerciseDate: exerciseDate ?? this.exerciseDate,
      slots: slots ?? this.slots,
    );
  }
}

class GoalExercisePlanDraft {
  final String exerciseId;
  final String doctorInstruction;
  final List<GoalExerciseScheduleDraft> scheduleConfig;

  const GoalExercisePlanDraft({
    required this.exerciseId,
    this.doctorInstruction = '',
    required this.scheduleConfig,
  });

  GoalExercisePlanDraft copyWith({
    String? exerciseId,
    String? doctorInstruction,
    List<GoalExerciseScheduleDraft>? scheduleConfig,
  }) {
    return GoalExercisePlanDraft(
      exerciseId: exerciseId ?? this.exerciseId,
      doctorInstruction: doctorInstruction ?? this.doctorInstruction,
      scheduleConfig: scheduleConfig ?? this.scheduleConfig,
    );
  }
}

class GoalModel {
  final String? id;
  final GoalCategory category;
  final String title;
  final String target;
  final String description;
  final GoalFrequency frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool remindersEnabled;
  final String notificationSchedule;
  final bool escalationAlert;
  final String educationNotes;
  final bool patientConsent;

  final List<String> selectedExerciseIds;
  final List<GoalExercisePlanDraft> selectedExercisePlans;

  const GoalModel({
    this.id,
    this.category = GoalCategory.steps,
    this.title = '',
    this.target = '',
    this.description = '',
    this.frequency = GoalFrequency.daily,
    this.startDate,
    this.endDate,
    this.remindersEnabled = false,
    this.notificationSchedule = '',
    this.escalationAlert = false,
    this.educationNotes = '',
    this.patientConsent = false,
    this.selectedExerciseIds = const [],
    this.selectedExercisePlans = const [],
  });

  GoalModel copyWith({
    String? id,
    GoalCategory? category,
    String? title,
    String? target,
    String? description,
    GoalFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    bool? remindersEnabled,
    String? notificationSchedule,
    bool? escalationAlert,
    String? educationNotes,
    bool? patientConsent,
    List<String>? selectedExerciseIds,
    List<GoalExercisePlanDraft>? selectedExercisePlans,
  }) {
    return GoalModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      target: target ?? this.target,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      notificationSchedule: notificationSchedule ?? this.notificationSchedule,
      escalationAlert: escalationAlert ?? this.escalationAlert,
      educationNotes: educationNotes ?? this.educationNotes,
      patientConsent: patientConsent ?? this.patientConsent,
      selectedExerciseIds: selectedExerciseIds ?? this.selectedExerciseIds,
      selectedExercisePlans:
          selectedExercisePlans ?? this.selectedExercisePlans,
    );
  }
}

class ExerciseModel {
  final String id;
  final String name;
  final int durationMinutes;
  final IconData icon;
  final String category;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.icon,
    required this.category,
  });
}

class SelectedExercisesSection extends StatelessWidget {
  final List<String> selectedIds;
  final bool readOnly;
  final VoidCallback onPickTap;
  final ValueChanged<String> onRemove;

  final List<Exercise> exercises;

  const SelectedExercisesSection({
    super.key,
    required this.selectedIds,
    required this.readOnly,
    required this.onPickTap,
    required this.onRemove,
    this.exercises = const [],
  });

  @override
  Widget build(BuildContext context) {
    final selected = exercises
        .where((e) => selectedIds.contains(e.id))
        .toList();
    final hasItems = selected.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assigned Exercises',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppPalette.secondaryBlue,
                    ),
                  ),
                  if (hasItems) ...[
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      '${selected.length} exercise${selected.length > 1 ? 's' : ''} · ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.secondaryBlue.withValues(alpha: .72),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!readOnly)
              TextButton.icon(
                onPressed: onPickTap,
                style: TextButton.styleFrom(
                  foregroundColor: AppPalette.secondaryBlue,
                ),
                icon: Icon(
                  hasItems ? Icons.edit_outlined : Icons.add_rounded,
                  size: 15,
                ),
                label: Text(
                  hasItems ? 'Edit' : 'Choose',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        if (!hasItems && !readOnly) ...[
          const SizedBox(height: AppSpacing.s8),
          _EmptyExercisesHint(),
        ],

        if (hasItems) ...[
          const SizedBox(height: AppSpacing.s10),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: selected
                .map(
                  (ex) => _ExerciseChip(
                    exercise: ex,
                    readOnly: readOnly,
                    onRemove: () => onRemove(ex.id),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _ExerciseChip extends StatelessWidget {
  final Exercise exercise;
  final bool readOnly;
  final VoidCallback onRemove;

  const _ExerciseChip({
    required this.exercise,
    required this.readOnly,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppPalette.secondaryBlue.withValues(alpha: 0.08),
        borderRadius: AppCorners.r20,
        border: Border.all(
          color: AppPalette.secondaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              exercise.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppPalette.secondaryBlue,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
          Text(
            '${(exercise.durationSeconds / 60).toStringAsFixed(2)}m',
            style: TextStyle(
              fontSize: 11,
              color: AppPalette.secondaryBlue.withValues(alpha: 0.65),
            ),
          ),
          if (!readOnly) ...[
            const SizedBox(width: AppSpacing.s4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: AppPalette.secondaryBlue.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyExercisesHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
      decoration: BoxDecoration(
        color: context.border.withValues(alpha: 0.05),
        borderRadius: AppCorners.r8,
        border: Border.all(
          color: context.border.withValues(alpha: 0.25),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.playlist_add_rounded,
            size: 28,
            color: context.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            'No exercises assigned yet',
            style: TextStyle(
              fontSize: 13,
              color: context.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
