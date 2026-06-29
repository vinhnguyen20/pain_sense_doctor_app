import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/tracking/data/models/sensor_snapshot_model.dart';
import 'package:app_doctor/features/tracking/domain/entites/tracking_log_detail.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tracking_log_detail_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TrackingLogDetailModel extends TrackingLogDetail
    with EntityConvertible<TrackingLogDetailModel, TrackingLogDetail> {
  @JsonKey(name: 'log_id')
  @override
  final String logId;

  @JsonKey(name: 'calculated_score')
  @override
  final int calculatedScore;

  @JsonKey(name: 'timestamp')
  @override
  final DateTime timestamp;

  @JsonKey(name: 'sensor_snapshot')
  @override
  final SensorSnapshotModel sensorSnapshot;

  const TrackingLogDetailModel({
    required this.logId,
    required this.calculatedScore,
    required this.timestamp,
    required this.sensorSnapshot,
  }) : super(
         logId: logId,
         calculatedScore: calculatedScore,
         timestamp: timestamp,
         sensorSnapshot: sensorSnapshot,
       );
  factory TrackingLogDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingLogDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrackingLogDetailModelToJson(this);

  @override
  TrackingLogDetail toEntity() {
    return TrackingLogDetail(
      logId: logId,
      calculatedScore: calculatedScore,
      sensorSnapshot: sensorSnapshot.toEntity(),
      timestamp: timestamp,
    );
  }

  factory TrackingLogDetailModel.fromEntity(TrackingLogDetail entity) {
    return TrackingLogDetailModel(
      logId: entity.logId,
      calculatedScore: entity.calculatedScore,
      sensorSnapshot: SensorSnapshotModel.fromEntity(entity.sensorSnapshot),
      timestamp: entity.timestamp,
    );
  }
}
