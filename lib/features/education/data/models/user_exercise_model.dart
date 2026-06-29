import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/education/data/models/exercise_model.dart';
import 'package:app_doctor/features/education/data/models/exercise_review_model.dart';
import 'package:app_doctor/features/education/data/models/exercise_session_model.dart';
import 'package:app_doctor/features/education/domain/entites/exercise_summary.dart';
import 'package:app_doctor/features/education/domain/entites/user_exercise.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_exercise_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ExerciseSummaryModel extends ExerciseSummary
    with EntityConvertible<ExerciseSummaryModel, ExerciseSummary> {
  @override
  @JsonKey(name: 'total_sessions_completed')
  final int totalSessionsCompleted;

  @override
  @JsonKey(name: 'compliance_rate')
  final double complianceRate;

  const ExerciseSummaryModel({
    required this.totalSessionsCompleted,
    required this.complianceRate,
  }) : super(
         totalSessionsCompleted: totalSessionsCompleted,
         complianceRate: complianceRate,
       );

  factory ExerciseSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseSummaryModelToJson(this);

  factory ExerciseSummaryModel.fromEntity(ExerciseSummary entity) {
    return ExerciseSummaryModel(
      totalSessionsCompleted: entity.totalSessionsCompleted,
      complianceRate: entity.complianceRate,
    );
  }

  @override
  ExerciseSummary toEntity() {
    return ExerciseSummary(
      totalSessionsCompleted: totalSessionsCompleted,
      complianceRate: complianceRate,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UserExerciseModel extends UserExercise
    with EntityConvertible<UserExerciseModel, UserExercise> {
  @override
  @JsonKey(name: 'user_id')
  final String userId;

  @override
  @JsonKey(name: 'exercise_id')
  final String exerciseId;

  @override
  @JsonKey(name: 'doctor_id')
  final String? doctorId;

  @override
  @JsonKey(name: 'assigned_date')
  final DateTime assignedDate;

  @override
  @JsonKey(name: 'start_date')
  final DateTime startDate;

  @override
  @JsonKey(name: 'end_date')
  final DateTime endDate;

  @override
  @JsonKey(name: 'schedule_config')
  final List<ScheduleConfigModel> scheduleConfig;

  @override
  @JsonKey(name: 'doctor_instruction')
  final String? doctorInstruction;

  @override
  @JsonKey(name: 'status')
  final String status;

  @override
  @JsonKey(name: 'times')
  final List<ExerciseSessionModel> times;

  @override
  @JsonKey(name: 'summary')
  final ExerciseSummaryModel summary;

  @override
  @JsonKey(name: 'data_exercise')
  final ExerciseModel? dataExercise;

  @override
  @JsonKey(name: 'data_exercise_review')
  final List<ExerciseReviewModel>? dataExerciseReview;

  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  @JsonKey(name: 'created_by')
  final String? createdBy;

  const UserExerciseModel({
    required super.id,
    required this.userId,
    required this.exerciseId,
    this.doctorId,
    required this.assignedDate,
    required this.startDate,
    required this.endDate,
    required this.scheduleConfig,
    this.doctorInstruction,
    required this.status,
    this.times = const [],
    required this.summary,
    this.createdAt,
    this.createdBy,
    this.dataExercise,
    this.dataExerciseReview,
  }) : super(
         userId: userId,
         exerciseId: exerciseId,
         doctorId: doctorId,
         assignedDate: assignedDate,
         startDate: startDate,
         endDate: endDate,
         scheduleConfig: scheduleConfig,
         doctorInstruction: doctorInstruction,
         status: status,
         times: times,
         summary: summary,
         createdAt: createdAt,
         createdBy: createdBy,
         dataExercise: dataExercise,
         dataExerciseReview: dataExerciseReview,
       );

  factory UserExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$UserExerciseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserExerciseModelToJson(this);

  factory UserExerciseModel.fromEntity(UserExercise entity) {
    return UserExerciseModel(
      id: entity.id,
      userId: entity.userId,
      exerciseId: entity.exerciseId,
      doctorId: entity.doctorId,
      assignedDate: entity.assignedDate,
      startDate: entity.startDate,
      endDate: entity.endDate,
      scheduleConfig: entity.scheduleConfig
          .map((e) => ScheduleConfigModel.fromEntity(e))
          .toList(),
      doctorInstruction: entity.doctorInstruction,
      status: entity.status,
      times: entity.times
          .map((e) => ExerciseSessionModel.fromEntity(e))
          .toList(),
      summary: ExerciseSummaryModel.fromEntity(entity.summary),
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
      dataExercise: entity.dataExercise != null
          ? ExerciseModel.fromEntity(entity.dataExercise!)
          : null,
      dataExerciseReview: entity.dataExerciseReview
          ?.map((e) => ExerciseReviewModel.fromEntity(e))
          .toList(),
    );
  }

  @override
  UserExercise toEntity() {
    return UserExercise(
      id: id,
      userId: userId,
      exerciseId: exerciseId,
      doctorId: doctorId,
      assignedDate: assignedDate,
      startDate: startDate,
      endDate: endDate,
      scheduleConfig: scheduleConfig.map((e) => e.toEntity()).toList(),
      doctorInstruction: doctorInstruction,
      status: status,
      times: times.map((e) => e.toEntity()).toList(),
      summary: summary.toEntity(),
      createdAt: createdAt,
      createdBy: createdBy,
      dataExercise: dataExercise?.toEntity(),
      dataExerciseReview: dataExerciseReview?.map((e) => e.toEntity()).toList(),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ScheduleConfigModel extends ScheduleConfig
    with EntityConvertible<ScheduleConfigModel, ScheduleConfig> {
  @override
  @JsonKey(name: 'exercise_date')
  final DateTime exerciseDate;

  @override
  @JsonKey(name: 'sessions_count')
  final int sessionsCount;

  @override
  @JsonKey(name: 'slots')
  final List<ScheduleSlotModel> slots;

  const ScheduleConfigModel({
    required this.exerciseDate,
    required this.sessionsCount,
    required this.slots,
  }) : super(
         exerciseDate: exerciseDate,
         sessionsCount: sessionsCount,
         slots: slots,
       );

  factory ScheduleConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleConfigModelToJson(this);

  factory ScheduleConfigModel.fromEntity(ScheduleConfig entity) {
    return ScheduleConfigModel(
      exerciseDate: entity.exerciseDate,
      sessionsCount: entity.sessionsCount,
      slots: entity.slots.map((e) => ScheduleSlotModel.fromEntity(e)).toList(),
    );
  }

  @override
  ScheduleConfig toEntity() {
    return ScheduleConfig(
      exerciseDate: exerciseDate,
      sessionsCount: sessionsCount,
      slots: slots.map((e) => e.toEntity()).toList(),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ScheduleSlotModel extends ScheduleSlot
    with EntityConvertible<ScheduleSlotModel, ScheduleSlot> {
  const ScheduleSlotModel({
    required super.period,
    required super.time,
    super.instruction,
  });

  factory ScheduleSlotModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleSlotModelFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleSlotModelToJson(this);

  factory ScheduleSlotModel.fromEntity(ScheduleSlot entity) {
    return ScheduleSlotModel(
      period: entity.period,
      time: entity.time,
      instruction: entity.instruction,
    );
  }

  @override
  ScheduleSlot toEntity() {
    return ScheduleSlot(period: period, time: time, instruction: instruction);
  }
}
