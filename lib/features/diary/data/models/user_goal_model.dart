import 'package:app_doctor/features/diary/data/models/goal_item_model.dart';
import 'package:app_doctor/presentations/pages/patient_monitor_detail/widgets/goal_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_goal_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserGoalModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'patient_id')
  final String patientId;

  @JsonKey(name: 'doctor_id')
  final String doctorId;

  @JsonKey(name: 'start_date')
  final DateTime startDate;

  @JsonKey(name: 'end_date')
  final DateTime endDate;

  @JsonKey(name: 'goal_items')
  final List<GoalItemModel> goalItems;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'created_by')
  final String createdBy;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const UserGoalModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.startDate,
    required this.endDate,
    required this.goalItems,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
  });

  factory UserGoalModel.fromJson(Map<String, dynamic> json) =>
      _$UserGoalModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserGoalModelToJson(this);

  GoalModel toGoalModel() {
    final primary = goalItems.isNotEmpty ? goalItems.first : null;
    final category = primary != null
        ? GoalCategory.fromGoalType(primary.type)
        : GoalCategory.steps;
    final yogaItem = goalItems
        .where(
          (item) => GoalCategory.fromGoalType(item.type) == GoalCategory.yoga,
        )
        .firstOrNull;

    // Build exercise plans from user_exercises (has schedule_config)
    final userExercises = yogaItem?.userExercises ?? const [];
    final List<String> selectedExerciseIds;
    final List<GoalExercisePlanDraft> selectedExercisePlans;

    if (userExercises.isNotEmpty) {
      final plans = userExercises.map((ue) {
        final realId = ue.resolvedExerciseId;
        final scheduleConfig = ue.scheduleConfig
            .map(
              (sc) => GoalExerciseScheduleDraft(
                exerciseDate: sc.exerciseDate,
                slots: sc.slots
                    .map(
                      (sl) => GoalExerciseSlotDraft(
                        period: sl.period,
                        time: sl.time,
                        instruction: sl.instruction ?? '',
                      ),
                    )
                    .toList(),
              ),
            )
            .toList();
        return GoalExercisePlanDraft(
          exerciseId: realId,
          scheduleConfig: scheduleConfig,
        );
      }).toList();
      selectedExerciseIds = plans.map((p) => p.exerciseId).toList();
      selectedExercisePlans = plans;
    } else {
      // Fallback: use userExerciseIds (last segment = real exercise ID)
      selectedExerciseIds = yogaItem?.userExerciseIds
              ?.map((id) => id.contains('+') ? id.split('+').first : id)
              .toList() ??
          const [];
      selectedExercisePlans = const [];
    }

    return GoalModel(
      id: id,
      category: category,
      title: primary?.label ?? '',
      target: primary?.minTarget.toString() ?? '',
      description: primary?.desc ?? '',
      startDate: startDate,
      endDate: endDate,
      selectedExerciseIds: selectedExerciseIds,
      selectedExercisePlans: selectedExercisePlans,
    );
  }
}
