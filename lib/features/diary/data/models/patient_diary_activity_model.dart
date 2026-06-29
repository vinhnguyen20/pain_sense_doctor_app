import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_activity.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/entity_convertible.dart';

part 'patient_diary_activity_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PatientDiaryActivityModel extends PatientDiaryActivity
    with EntityConvertible<PatientDiaryActivityModel, PatientDiaryActivity> {
  @JsonKey(name: 'label')
  @override
  final String label;

  @JsonKey(name: 'type', fromJson: GoalType.fromString, toJson: _typeToJson)
  @override
  final GoalType type;

  static String _typeToJson(GoalType type) => type.toApiString();

  @JsonKey(name: 'desc')
  @override
  final String desc;

  @JsonKey(name: 'unit')
  @override
  final String unit;

  @JsonKey(name: 'min_target')
  @override
  final double minTarget;

  @JsonKey(name: 'actual')
  @override
  final double actual;

  @JsonKey(name: 'percent')
  @override
  final double percent;

  @JsonKey(name: 'emoji')
  @override
  final String emoji;

  @JsonKey(name: 'display')
  @override
  final String display;

  @JsonKey(name: 'user_exercises')
  @override
  final List<DiaryExerciseModel>? userExercises;

  @JsonKey(name: 'adherence')
  @override
  final DiaryAdherenceModel? adherence;

  @JsonKey(name: 'start_date')
  @override
  final String? startDate;

  @JsonKey(name: 'end_date')
  @override
  final String? endDate;

  const PatientDiaryActivityModel({
    required this.label,
    required this.type,
    required this.desc,
    required this.unit,
    required this.minTarget,
    required this.actual,
    required this.percent,
    required this.emoji,
    required this.display,
    this.userExercises,
    this.adherence,
    this.startDate,
    this.endDate,
  }) : super(
         label: label,
         type: type,
         desc: desc,
         unit: unit,
         minTarget: minTarget,
         actual: actual,
         percent: percent,
         emoji: emoji,
         display: display,
         userExercises: userExercises,
         adherence: adherence,
         startDate: startDate,
         endDate: endDate,
       );

  factory PatientDiaryActivityModel.fromJson(Map<String, dynamic> json) =>
      _$PatientDiaryActivityModelFromJson(json);

  Map<String, dynamic> toJson() => _$PatientDiaryActivityModelToJson(this);

  @override
  PatientDiaryActivityModel fromEntity(PatientDiaryActivity entity) {
    return PatientDiaryActivityModel(
      label: entity.label,
      type: entity.type,
      desc: entity.desc,
      unit: entity.unit,
      minTarget: entity.minTarget,
      actual: entity.actual,
      percent: entity.percent,
      emoji: entity.emoji,
      display: entity.display,
      userExercises: entity.userExercises
          ?.map(
            (e) => DiaryExerciseModel(
              exerciseId: e.exerciseId,
              exerciseName: e.exerciseName,
            ),
          )
          .toList(),
      adherence: entity.adherence != null
          ? DiaryAdherenceModel(
              score: entity.adherence!.score,
              level: entity.adherence!.level,
            )
          : null,
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }

  @override
  PatientDiaryActivity toEntity() {
    return PatientDiaryActivity(
      label: label,
      type: type,
      desc: desc,
      unit: unit,
      minTarget: minTarget,
      actual: actual,
      percent: percent,
      emoji: emoji,
      display: display,
      userExercises: userExercises
          ?.map(
            (e) => DiaryExercise(
              exerciseId: e.exerciseId,
              exerciseName: e.exerciseName,
            ),
          )
          .toList(),
      adherence: adherence != null
          ? DiaryAdherence(score: adherence!.score, level: adherence!.level)
          : null,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

@JsonSerializable()
class DiaryExerciseModel extends DiaryExercise {
  @JsonKey(name: 'exercise_id')
  @override
  final String exerciseId;

  @JsonKey(name: 'exercise_name')
  @override
  final String exerciseName;

  const DiaryExerciseModel({
    required this.exerciseId,
    required this.exerciseName,
  }) : super(exerciseId: exerciseId, exerciseName: exerciseName);

  factory DiaryExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$DiaryExerciseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiaryExerciseModelToJson(this);
}

@JsonSerializable()
class DiaryAdherenceModel extends DiaryAdherence {
  @JsonKey(name: 'score')
  @override
  final double? score;

  @JsonKey(name: 'level')
  @override
  final String? level;

  const DiaryAdherenceModel({this.score, this.level})
    : super(score: score, level: level);

  factory DiaryAdherenceModel.fromJson(Map<String, dynamic> json) =>
      _$DiaryAdherenceModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiaryAdherenceModelToJson(this);
}
