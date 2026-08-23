import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'goal_item_model.g.dart';

class UserExerciseScheduleSlot {
  final String period;
  final String time;
  final String? instruction;
  final bool isCompleted;

  const UserExerciseScheduleSlot({
    required this.period,
    required this.time,
    this.instruction,
    this.isCompleted = false,
  });

  factory UserExerciseScheduleSlot.fromJson(Map<String, dynamic> json) =>
      UserExerciseScheduleSlot(
        period: json['period'] as String? ?? 'morning',
        time: json['time'] as String? ?? '07:00',
        instruction: json['instruction'] as String?,
        isCompleted: json['is_completed'] as bool? ?? false,
      );
}

class UserExerciseScheduleConfig {
  final DateTime exerciseDate;
  final int sessionsCount;
  final List<UserExerciseScheduleSlot> slots;
  final int sessionsCompleted;
  final int sessionsTotal;

  const UserExerciseScheduleConfig({
    required this.exerciseDate,
    required this.sessionsCount,
    required this.slots,
    this.sessionsCompleted = 0,
    this.sessionsTotal = 0,
  });

  factory UserExerciseScheduleConfig.fromJson(Map<String, dynamic> json) =>
      UserExerciseScheduleConfig(
        exerciseDate: DateTime.parse(json['exercise_date'] as String),
        sessionsCount: (json['sessions_count'] as num?)?.toInt() ?? 1,
        slots:
            (json['slots'] as List<dynamic>?)
                ?.map(
                  (e) => UserExerciseScheduleSlot.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            const [],
        sessionsCompleted: (json['sessions_completed'] as num?)?.toInt() ?? 0,
        sessionsTotal: (json['sessions_total'] as num?)?.toInt() ?? 0,
      );
}

class UserExerciseItem {
  final String id;
  final String? exerciseId;
  final String? name;
  final List<UserExerciseScheduleConfig> scheduleConfig;

  const UserExerciseItem({
    required this.id,
    this.exerciseId,
    this.name,
    required this.scheduleConfig,
  });

  String get resolvedExerciseId {
    if (exerciseId != null && exerciseId!.isNotEmpty) return exerciseId!;
    if (id.contains('+')) return id.split('+').first;
    return id;
  }

  factory UserExerciseItem.fromJson(Map<String, dynamic> json) =>
      UserExerciseItem(
        id: json['id'] as String? ?? '',
        exerciseId: json['exercise_id'] as String?,
        name: json['name'] as String?,
        scheduleConfig:
            (json['schedule_config'] as List<dynamic>?)
                ?.map(
                  (e) => UserExerciseScheduleConfig.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            const [],
      );
}

@JsonSerializable(explicitToJson: true)
class GoalItemModel {
  @JsonKey(name: 'type', fromJson: GoalType.fromString, toJson: _typeToJson)
  final GoalType type;

  static String _typeToJson(GoalType type) => type.toApiString();

  @JsonKey(name: 'min_target', defaultValue: 0)
  final int minTarget;

  @JsonKey(name: 'unit', defaultValue: '')
  final String unit;

  @JsonKey(name: 'label', defaultValue: '')
  final String label;

  @JsonKey(name: 'desc', defaultValue: '')
  final String desc;

  @JsonKey(name: 'user_exercise_ids')
  final List<String>? userExerciseIds;

  @JsonKey(name: 'user_exercises', includeToJson: false)
  final List<UserExerciseItem>? userExercises;

  const GoalItemModel({
    required this.type,
    required this.minTarget,
    required this.unit,
    required this.label,
    required this.desc,
    this.userExerciseIds,
    this.userExercises,
  });

  factory GoalItemModel.fromJson(Map<String, dynamic> json) =>
      _$GoalItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$GoalItemModelToJson(this);
}
