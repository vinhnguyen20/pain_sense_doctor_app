import 'package:equatable/equatable.dart';

class SensorSnapshot extends Equatable {
  final int time;
  final int timeAlive;
  final int prevDay;
  final bool status;
  final double temp;
  final double pressure;
  final double humidity;
  final int steps;
  final int cadence;
  final String label;
  final int prevStep;

  const SensorSnapshot({
    required this.time,
    required this.timeAlive,
    required this.prevDay,
    required this.status,
    required this.temp,
    required this.pressure,
    required this.humidity,
    required this.steps,
    required this.cadence,
    required this.label,
    this.prevStep = 1,
  });

  @override
  List<Object?> get props => [
    time,
    timeAlive,
    prevDay,
    status,
    temp,
    pressure,
    humidity,
    steps,
    cadence,
    label,
    prevStep,
  ];
}
