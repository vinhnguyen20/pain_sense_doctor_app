import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:intl/intl.dart';

class CreateUserGoalWithExercisesRequest {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final List<UserGoalExerciseAssignment> exercises;
  final List<UserGoalItem> goalItems;

  const CreateUserGoalWithExercisesRequest({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.exercises,
    required this.goalItems,
  });

  static final DateFormat _apiDateFormatter = DateFormat('yyyy-MM-dd');

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'start_date': _apiDateFormatter.format(startDate),
      'end_date': _apiDateFormatter.format(endDate),
      'exercises': exercises.map((item) => item.toJson()).toList(),
      'goal_items': goalItems.map((item) => item.toJson()).toList(),
    };
  }
}

class UserGoalExerciseAssignment {
  final String exerciseId;
  final DateTime assignedDate;
  final DateTime startDate;
  final DateTime endDate;
  final String? doctorInstruction;
  final List<UserGoalScheduleConfig> scheduleConfig;

  const UserGoalExerciseAssignment({
    required this.exerciseId,
    required this.assignedDate,
    required this.startDate,
    required this.endDate,
    this.doctorInstruction,
    required this.scheduleConfig,
  });

  static final DateFormat _apiDateFormatter = DateFormat('yyyy-MM-dd');

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'assigned_date': _apiDateFormatter.format(assignedDate),
      'start_date': _apiDateFormatter.format(startDate),
      'end_date': _apiDateFormatter.format(endDate),
      if (doctorInstruction != null) 'doctor_instruction': doctorInstruction,
      'schedule_config': scheduleConfig.map((item) => item.toJson()).toList(),
    };
  }
}

class UserGoalScheduleConfig {
  final DateTime exerciseDate;
  final int sessionsCount;
  final List<UserGoalScheduleSlot> slots;

  const UserGoalScheduleConfig({
    required this.exerciseDate,
    required this.sessionsCount,
    required this.slots,
  });

  static final DateFormat _apiDateFormatter = DateFormat('yyyy-MM-dd');

  Map<String, dynamic> toJson() {
    return {
      'exercise_date': _apiDateFormatter.format(exerciseDate),
      'sessions_count': sessionsCount,
      'slots': slots.map((item) => item.toJson()).toList(),
    };
  }
}

class UserGoalScheduleSlot {
  final String period;
  final String time;
  final String? instruction;

  const UserGoalScheduleSlot({
    required this.period,
    required this.time,
    this.instruction,
  });

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'time': time,
      if (instruction != null) 'instruction': instruction,
    };
  }
}

class UserGoalItem {
  final GoalType type;
  final num minTarget;
  final String unit;
  final String label;
  final String desc;
  final List<String>? userExerciseIds;

  const UserGoalItem({
    required this.type,
    required this.minTarget,
    required this.unit,
    required this.label,
    required this.desc,
    this.userExerciseIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toApiString(),
      'min_target': minTarget,
      'unit': unit,
      'label': label,
      'desc': desc,
      if (userExerciseIds != null) 'user_exercise_ids': userExerciseIds,
    };
  }
}

class UpdateUserGoalRequest {
  final String goalId;
  final String patientId;
  final DateTime startDate;
  final DateTime endDate;
  final List<UserGoalExerciseAssignment> exercises;
  final List<UserGoalItem> goalItems;

  const UpdateUserGoalRequest({
    required this.goalId,
    required this.patientId,
    required this.startDate,
    required this.endDate,
    required this.exercises,
    required this.goalItems,
  });

  static final DateFormat _fmt = DateFormat('yyyy-MM-dd');

  String get compositeId => goalId;

  Map<String, dynamic> toJson() => {
    'user_id': patientId,
    'start_date': _fmt.format(startDate),
    'end_date': _fmt.format(endDate),
    'user_exercises': exercises.map((e) => e.toJson()).toList(),
    'goal_items': goalItems.map((e) => e.toJson()).toList(),
  };
}
