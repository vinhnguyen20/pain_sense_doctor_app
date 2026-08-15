import 'package:app_doctor/features/diary/domain/entites/goal_type.dart';
import 'package:equatable/equatable.dart';

class PatientDiaryActivity extends Equatable {
  final String label;
  final GoalType type;
  final String desc;
  final String unit;
  final double minTarget;
  final double actual;
  final double percent;
  final String emoji;
  final String display;
  final List<DiaryExercise>? userExercises;
  final DiaryAdherence? adherence;
  final String? startDate;
  final String? endDate;

  const PatientDiaryActivity({
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
  });

  @override
  List<Object?> get props => [
    label,
    type,
    desc,
    unit,
    minTarget,
    actual,
    percent,
    emoji,
    display,
    userExercises,
    adherence,
    startDate,
    endDate,
  ];
}

class DiaryExercise extends Equatable {
  final String exerciseId;
  final String exerciseName;

  const DiaryExercise({required this.exerciseId, required this.exerciseName});

  @override
  List<Object?> get props => [exerciseId, exerciseName];
}

class DiaryAdherence extends Equatable {
  final double? score;
  final String? level;

  const DiaryAdherence({this.score, this.level});

  @override
  List<Object?> get props => [score, level];
}
