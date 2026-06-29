import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/tracking/domain/entites/sensor_snapshot.dart';
import 'package:json_annotation/json_annotation.dart';
part 'sensor_snapshot_model.g.dart';

@JsonSerializable()
class SensorSnapshotModel extends SensorSnapshot
    with EntityConvertible<SensorSnapshotModel, SensorSnapshot> {
  @JsonKey(name: 'time', defaultValue: 0)
  @override
  final int time;

  @JsonKey(name: 'time_alive', defaultValue: 0)
  @override
  final int timeAlive;

  @JsonKey(name: 'prev_day', defaultValue: 0)
  @override
  final int prevDay;

  @JsonKey(name: 'status', defaultValue: false)
  @override
  final bool status;

  @JsonKey(name: 'temp', defaultValue: 0.0)
  @override
  final double temp;

  @JsonKey(name: 'pressure', defaultValue: 0.0)
  @override
  final double pressure;

  @JsonKey(name: 'humidity', defaultValue: 0.0)
  @override
  final double humidity;

  @JsonKey(name: 'steps', defaultValue: 0)
  @override
  final int steps;

  @JsonKey(name: 'cadence', defaultValue: 0)
  @override
  final int cadence;

  @JsonKey(name: 'label', defaultValue: '')
  @override
  final String label;
  @JsonKey(name: 'prev_step', defaultValue: 1)
  @override
  final int prevStep;

  const SensorSnapshotModel({
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
  }) : super(
         time: time,
         timeAlive: timeAlive,
         prevDay: prevDay,
         status: status,
         temp: temp,
         pressure: pressure,
         humidity: humidity,
         steps: steps,
         cadence: cadence,
         label: label,
         prevStep: prevStep,
       );

  factory SensorSnapshotModel.fromJson(Map<String, dynamic> json) =>
      _$SensorSnapshotModelFromJson(json);

  Map<String, dynamic> toJson() => _$SensorSnapshotModelToJson(this);

  @override
  SensorSnapshot toEntity() => SensorSnapshot(
    time: time,
    timeAlive: timeAlive,
    prevDay: prevDay,
    status: status,
    temp: temp,
    pressure: pressure,
    humidity: humidity,
    steps: steps,
    cadence: cadence,
    label: label,
    prevStep: prevStep,
  );

  factory SensorSnapshotModel.fromEntity(SensorSnapshot entity) =>
      SensorSnapshotModel(
        time: entity.time,
        timeAlive: entity.timeAlive,
        prevDay: entity.prevDay,
        status: entity.status,
        temp: entity.temp,
        pressure: entity.pressure,
        humidity: entity.humidity,
        steps: entity.steps,
        cadence: entity.cadence,
        label: entity.label,
        prevStep: entity.prevStep,
      );
}
