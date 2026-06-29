import 'package:app_doctor/features/diary/domain/entites/diary_current_date.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/entity_convertible.dart';

part 'diary_current_date_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DiaryTaskModel extends DiaryTask
    with EntityConvertible<DiaryTaskModel, DiaryTask> {
  @JsonKey(name: 'label')
  @override
  final String label;

  @JsonKey(name: 'status')
  @override
  final String status;

  const DiaryTaskModel({required this.label, required this.status})
    : super(label: label, status: status);

  factory DiaryTaskModel.fromJson(Map<String, dynamic> json) =>
      _$DiaryTaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiaryTaskModelToJson(this);

  @override
  DiaryTaskModel fromEntity(DiaryTask model) =>
      DiaryTaskModel(label: model.label, status: model.status);

  @override
  DiaryTask toEntity() => DiaryTask(label: label, status: status);
}

@JsonSerializable(explicitToJson: true)
class DiaryCurrentDateModel extends DiaryCurrentDate
    with EntityConvertible<DiaryCurrentDateModel, DiaryCurrentDate> {
  @JsonKey(name: 'tasks_done', defaultValue: 0)
  @override
  final int tasksDone;

  @JsonKey(name: 'tasks_total', defaultValue: 0)
  @override
  final int tasksTotal;

  @JsonKey(name: 'tasks', defaultValue: [])
  final List<DiaryTaskModel> taskModels;

  DiaryCurrentDateModel({
    required this.tasksDone,
    required this.tasksTotal,
    required this.taskModels,
  }) : super(tasksDone: tasksDone, tasksTotal: tasksTotal, tasks: taskModels);

  factory DiaryCurrentDateModel.fromJson(Map<String, dynamic> json) =>
      _$DiaryCurrentDateModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiaryCurrentDateModelToJson(this);

  @override
  DiaryCurrentDateModel fromEntity(DiaryCurrentDate model) =>
      DiaryCurrentDateModel(
        tasksDone: model.tasksDone,
        tasksTotal: model.tasksTotal,
        taskModels: model.tasks
            .map((t) => DiaryTaskModel(label: t.label, status: t.status))
            .toList(),
      );

  @override
  DiaryCurrentDate toEntity() => DiaryCurrentDate(
    tasksDone: tasksDone,
    tasksTotal: tasksTotal,
    tasks: taskModels.map((t) => t.toEntity()).toList(),
  );
}
