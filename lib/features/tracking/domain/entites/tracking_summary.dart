import 'package:equatable/equatable.dart';

class TrackingSummary extends Equatable {
  final double totalMinWalk;
  final double totalTimeAlive;
  final double posture;
  final double lbpScore;
  final int totalSteps;
  final double avgHumidity;
  final double avgPressure;
  final double avgTemp;
  final int cadence;
  final String latestLabel;
  final String lbpFormula;

  const TrackingSummary({
    required this.totalMinWalk,
    required this.totalTimeAlive,
    required this.posture,
    required this.lbpScore,
    required this.totalSteps,
    required this.avgHumidity,
    required this.avgPressure,
    required this.avgTemp,
    required this.cadence,
    required this.latestLabel,
    this.lbpFormula = '',
  });

  @override
  List<Object?> get props => [
    totalMinWalk,
    totalTimeAlive,
    posture,
    lbpScore,
    totalSteps,
    avgHumidity,
    avgPressure,
    avgTemp,
    cadence,
    latestLabel,
    lbpFormula,
  ];
}
