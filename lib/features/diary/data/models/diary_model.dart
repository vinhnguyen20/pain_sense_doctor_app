import 'package:app_doctor/features/diary/domain/entites/diary.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/entity_convertible.dart';

part 'diary_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DiaryActivityModel extends DiaryActivity
    with EntityConvertible<DiaryActivityModel, DiaryActivity> {
  @JsonKey(name: 'description')
  @override
  final String description;

  @JsonKey(name: 'type')
  @override
  final String type;

  @JsonKey(name: 'duration_minutes')
  @override
  final int durationMinutes;

  const DiaryActivityModel({
    required this.description,
    required this.type,
    required this.durationMinutes,
  }) : super(
         description: description,
         type: type,
         durationMinutes: durationMinutes,
       );

  factory DiaryActivityModel.fromJson(Map<String, dynamic> json) =>
      _$DiaryActivityModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiaryActivityModelToJson(this);
  @override
  DiaryActivityModel fromEntity(DiaryActivity model) {
    return DiaryActivityModel(
      description: model.description,
      type: model.type,
      durationMinutes: model.durationMinutes,
    );
  }

  @override
  DiaryActivity toEntity() {
    return DiaryActivity(
      description: description,
      type: type,
      durationMinutes: durationMinutes,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class DiaryModel extends Diary with EntityConvertible<DiaryModel, Diary> {
  @JsonKey(name: 'id')
  @override
  final String id;

  @JsonKey(name: 'user_id')
  @override
  final String userId;

  @JsonKey(name: 'comment')
  @override
  final String? comment;

  @JsonKey(name: 'note')
  @override
  final String? note;

  @JsonKey(name: 'created_at')
  @override
  final DateTime createdAt;

  @JsonKey(name: 'entry_date')
  @override
  final DateTime entryDate;

  @JsonKey(name: 'activity')
  final DiaryActivityModel activityModel;

  DiaryModel({
    required this.id,
    required this.userId,
    this.comment,
    this.note,
    required this.createdAt,
    required this.entryDate,
    required this.activityModel,
  }) : super(
         id: id,
         userId: userId,
         comment: comment,
         note: note,
         createdAt: createdAt,
         entryDate: entryDate,
         activity: activityModel,
       );

  factory DiaryModel.fromJson(Map<String, dynamic> json) =>
      _$DiaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiaryModelToJson(this);
  @override
  DiaryModel fromEntity(Diary model) {
    return DiaryModel(
      id: model.id,
      userId: model.userId,
      comment: model.comment,
      note: model.note,
      createdAt: model.createdAt,
      entryDate: model.entryDate,
      activityModel: DiaryActivityModel(
        description: model.activity.description,
        type: model.activity.type,
        durationMinutes: model.activity.durationMinutes,
      ),
    );
  }

  @override
  Diary toEntity() {
    return Diary(
      id: id,
      userId: userId,
      comment: comment,
      note: note,
      createdAt: createdAt,
      entryDate: entryDate,
      activity: DiaryActivity(
        description: activityModel.description,
        type: activityModel.type,
        durationMinutes: activityModel.durationMinutes,
      ),
    );
  }
}
