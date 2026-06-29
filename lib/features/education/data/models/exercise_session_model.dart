import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/education/domain/entites/excercise_session.dart';
import 'package:app_doctor/features/education/domain/entites/user_feedback.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise_session_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserFeedbackModel extends UserFeedback
    with EntityConvertible<UserFeedbackModel, UserFeedback> {
  const UserFeedbackModel({super.comment, required super.status});

  factory UserFeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$UserFeedbackModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserFeedbackModelToJson(this);

  factory UserFeedbackModel.fromEntity(UserFeedback entity) {
    return UserFeedbackModel(comment: entity.comment, status: entity.status);
  }

  @override
  UserFeedback toEntity() {
    return UserFeedback(comment: comment, status: status);
  }
}

@JsonSerializable(explicitToJson: true)
class ExerciseSessionModel extends ExerciseSession
    with EntityConvertible<ExerciseSessionModel, ExerciseSession> {
  @JsonKey(name: 'doctorFeedback')
  final UserFeedbackModel? _doctorFeedbackModel;

  @JsonKey(name: 'userFeedback')
  final UserFeedbackModel? _userFeedbackModel;

  ExerciseSessionModel({
    required super.sessionId,
    required super.takenDate,
    required super.startTime,
    required super.endTime,
    required super.durationSeconds,
    super.matchedSlot,
    super.posturePositionUser,
    super.startPainLevel,
    super.endPainLevel,
    required super.logIds,
    UserFeedbackModel? doctorFeedback,
    UserFeedbackModel? userFeedback,
  }) : _doctorFeedbackModel = doctorFeedback,
       _userFeedbackModel = userFeedback,
       super(
         doctorFeedback: doctorFeedback as UserFeedback?,
         userFeedback: userFeedback as UserFeedback?,
       );

  @override
  UserFeedbackModel? get doctorFeedback => _doctorFeedbackModel;

  @override
  UserFeedbackModel? get userFeedback => _userFeedbackModel;

  factory ExerciseSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExerciseSessionModelToJson(this);

  factory ExerciseSessionModel.fromEntity(ExerciseSession entity) {
    return ExerciseSessionModel(
      sessionId: entity.sessionId,
      takenDate: entity.takenDate,
      startTime: entity.startTime,
      endTime: entity.endTime,
      durationSeconds: entity.durationSeconds,
      matchedSlot: entity.matchedSlot,
      posturePositionUser: entity.posturePositionUser,
      startPainLevel: entity.startPainLevel,
      endPainLevel: entity.endPainLevel,
      logIds: entity.logIds,
      doctorFeedback: entity.doctorFeedback != null
          ? UserFeedbackModel.fromEntity(entity.doctorFeedback!)
          : null,
      userFeedback: entity.userFeedback != null
          ? UserFeedbackModel.fromEntity(entity.userFeedback!)
          : null,
    );
  }

  @override
  ExerciseSession toEntity() => ExerciseSession(
    sessionId: sessionId,
    takenDate: takenDate,
    startTime: startTime,
    endTime: endTime,
    durationSeconds: durationSeconds,
    matchedSlot: matchedSlot,
    posturePositionUser: posturePositionUser,
    startPainLevel: startPainLevel,
    endPainLevel: endPainLevel,
    logIds: logIds,
    doctorFeedback: doctorFeedback != null
        ? UserFeedbackModel.fromEntity(doctorFeedback!)
        : null,
    userFeedback: userFeedback != null
        ? UserFeedbackModel.fromEntity(userFeedback!)
        : null,
  );
}
