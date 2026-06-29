import 'package:app_doctor/features/tracking/domain/entites/sensor_snapshot.dart';
import 'package:equatable/equatable.dart';

class TrackingLogDetail extends Equatable {
  final String logId;
  final int calculatedScore;
  final DateTime timestamp;
  final SensorSnapshot sensorSnapshot;

  const TrackingLogDetail({
    required this.logId,
    required this.calculatedScore,
    required this.timestamp,
    required this.sensorSnapshot,
  });

  @override
  List<Object?> get props => [
    logId,
    calculatedScore,
    timestamp,
    sensorSnapshot,
  ];
}
