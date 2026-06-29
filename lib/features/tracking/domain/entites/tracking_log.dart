import 'package:equatable/equatable.dart';
import 'tracking_log_detail.dart';
import 'tracking_summary.dart';

class TrackingLog extends Equatable {
  final String id;
  final String timezone;
  final String syncStatus;
  final DateTime logDate;
  final String? deviceId;
  final DateTime lastUpdated;
  final String userId;
  final List<TrackingLogDetail> logDetails;
  final TrackingSummary summary;

  const TrackingLog({
    required this.id,
    required this.timezone,
    required this.syncStatus,
    required this.logDate,
    this.deviceId,
    required this.lastUpdated,
    required this.userId,
    required this.logDetails,
    required this.summary,
  });

  TrackingLog copyWith({
    String? id,
    String? timezone,
    String? syncStatus,
    DateTime? logDate,
    String? deviceId,
    DateTime? lastUpdated,
    String? userId,
    List<TrackingLogDetail>? logDetails,
    TrackingSummary? summary,
  }) {
    return TrackingLog(
      id: id ?? this.id,
      timezone: timezone ?? this.timezone,
      syncStatus: syncStatus ?? this.syncStatus,
      logDate: logDate ?? this.logDate,
      deviceId: deviceId ?? this.deviceId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userId: userId ?? this.userId,
      logDetails: logDetails ?? this.logDetails,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [
    id,
    timezone,
    syncStatus,
    logDate,
    deviceId,
    lastUpdated,
    userId,
    logDetails,
    summary,
  ];
}
