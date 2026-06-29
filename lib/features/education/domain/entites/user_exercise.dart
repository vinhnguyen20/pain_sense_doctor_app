import 'package:app_doctor/features/education/domain/entites/excercise_session.dart';
import 'package:app_doctor/features/education/domain/entites/exercise_review.dart';
import 'package:app_doctor/features/education/domain/entites/exercise_summary.dart';
import 'package:equatable/equatable.dart';
import 'package:app_doctor/features/education/domain/entites/exercise.dart';

class UserExercise extends Equatable {
  final String id;
  final String userId;
  final String exerciseId;
  final String? doctorId;
  final DateTime assignedDate;
  final DateTime startDate;
  final DateTime endDate;
  final List<ScheduleConfig> scheduleConfig;
  final String? doctorInstruction;
  final String status;
  final List<ExerciseSession> times;
  final ExerciseSummary summary;
  final DateTime? createdAt;
  final String? createdBy;
  final Exercise? dataExercise;
  final List<ExerciseReview>? dataExerciseReview;

  const UserExercise({
    required this.id,
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
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    exerciseId,
    doctorId,
    assignedDate,
    startDate,
    endDate,
    scheduleConfig,
    doctorInstruction,
    status,
    times,
    summary,
    createdAt,
    createdBy,
    dataExercise,
    dataExerciseReview,
  ];
}

//ScheduleConfig
class ScheduleConfig extends Equatable {
  final DateTime exerciseDate;
  final int sessionsCount;
  final List<ScheduleSlot> slots;

  const ScheduleConfig({
    required this.exerciseDate,
    required this.sessionsCount,
    required this.slots,
  });

  @override
  List<Object?> get props => [exerciseDate, sessionsCount, slots];
}

//ScheduleSlot
class ScheduleSlot extends Equatable {
  final String period;
  final String time;
  final String? instruction;

  const ScheduleSlot({
    required this.period,
    required this.time,
    this.instruction,
  });

  @override
  List<Object?> get props => [period, time, instruction];
}
