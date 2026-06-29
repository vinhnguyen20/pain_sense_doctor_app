import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/tracking/domain/entites/tracking_log.dart';
import 'package:json_annotation/json_annotation.dart';
import 'tracking_log_detail_model.dart';
import 'tracking_summary_model.dart';

part 'tracking_log_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TrackingLogModel extends TrackingLog
    with EntityConvertible<TrackingLogModel, TrackingLog> {
  @JsonKey(name: 'id')
  @override
  final String id;

  @JsonKey(name: 'timezone')
  @override
  final String timezone;

  @JsonKey(name: 'sync_status')
  @override
  final String syncStatus;

  @JsonKey(name: 'log_date')
  @override
  final DateTime logDate;

  @JsonKey(name: 'device_id', defaultValue: '')
  @override
  final String deviceId;

  @JsonKey(name: 'last_updated')
  @override
  final DateTime lastUpdated;

  @JsonKey(name: 'user_id')
  @override
  final String userId;

  @JsonKey(name: 'log_details')
  @override
  final List<TrackingLogDetailModel> logDetails;

  @JsonKey(name: 'summary')
  @override
  final TrackingSummaryModel summary;

  const TrackingLogModel({
    required this.id,
    required this.timezone,
    required this.syncStatus,
    required this.logDate,
    required this.deviceId,
    required this.lastUpdated,
    required this.userId,
    required this.logDetails,
    required this.summary,
  }) : super(
         id: id,
         timezone: timezone,
         syncStatus: syncStatus,
         logDate: logDate,
         deviceId: deviceId,
         lastUpdated: lastUpdated,
         userId: userId,
         logDetails: logDetails,
         summary: summary,
       );

  factory TrackingLogModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrackingLogModelToJson(this);

  @override
  TrackingLog toEntity() {
    return TrackingLog(
      id: id,
      timezone: timezone,
      syncStatus: syncStatus,
      logDate: logDate,
      deviceId: deviceId,
      lastUpdated: lastUpdated,
      userId: userId,
      logDetails: logDetails.map((e) => e.toEntity()).toList(),
      summary: summary.toEntity(),
    );
  }

  factory TrackingLogModel.fromEntity(TrackingLog entity) {
    return TrackingLogModel(
      id: entity.id,
      timezone: entity.timezone,
      syncStatus: entity.syncStatus,
      logDate: entity.logDate,
      deviceId: entity.deviceId ?? '',
      lastUpdated: entity.lastUpdated,
      userId: entity.userId,
      logDetails: entity.logDetails
          .map((e) => TrackingLogDetailModel.fromEntity(e))
          .toList(),
      summary: TrackingSummaryModel.fromEntity(entity.summary),
    );
  }
}
