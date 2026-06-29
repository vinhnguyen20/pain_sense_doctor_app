import 'package:equatable/equatable.dart';

class ExerciseSummary extends Equatable {
  final int totalSessionsCompleted;
  final double complianceRate;

  const ExerciseSummary({
    required this.totalSessionsCompleted,
    required this.complianceRate,
  });

  @override
  List<Object?> get props => [totalSessionsCompleted, complianceRate];
}
