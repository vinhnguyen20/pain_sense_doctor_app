import 'package:app_doctor/features/education/domain/entites/user_feedback.dart';
import 'package:equatable/equatable.dart';

class ExerciseSession extends Equatable {
  final String sessionId;
  final DateTime takenDate;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final String? matchedSlot;
  final String? posturePositionUser;
  final int? startPainLevel;
  final int? endPainLevel;
  final List<String> logIds;
  final UserFeedback? doctorFeedback;
  final UserFeedback? userFeedback;

  const ExerciseSession({
    required this.sessionId,
    required this.takenDate,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    this.matchedSlot,
    this.posturePositionUser,
    this.startPainLevel,
    this.endPainLevel,
    required this.logIds,
    this.doctorFeedback,
    this.userFeedback,
  });

  @override
  List<Object?> get props => [
    sessionId,
    takenDate,
    startTime,
    endTime,
    durationSeconds,
    matchedSlot,
    posturePositionUser,
    startPainLevel,
    endPainLevel,
    logIds,
    doctorFeedback,
    userFeedback,
  ];
}
