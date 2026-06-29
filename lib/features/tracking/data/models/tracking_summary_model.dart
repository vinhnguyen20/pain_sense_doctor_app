import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/tracking/domain/entites/tracking_summary.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tracking_summary_model.g.dart';

@JsonSerializable()
class TrackingSummaryModel extends TrackingSummary
    with EntityConvertible<TrackingSummaryModel, TrackingSummary> {
  @JsonKey(name: 'total_min_walk', defaultValue: 0.0)
  @override
  final double totalMinWalk;

  @JsonKey(name: 'total_time_alive', defaultValue: 0.0)
  @override
  final double totalTimeAlive;

  @JsonKey(name: 'posture', defaultValue: 0.0)
  @override
  final double posture;

  @JsonKey(name: 'lbp_score', defaultValue: 0.0)
  @override
  final double lbpScore;

  @JsonKey(name: 'total_steps', defaultValue: 0)
  @override
  final int totalSteps;

  @JsonKey(name: 'avg_humidity', defaultValue: 0.0)
  @override
  final double avgHumidity;

  @JsonKey(name: 'avg_pressure', defaultValue: 0.0)
  @override
  final double avgPressure;

  @JsonKey(name: 'avg_temp', defaultValue: 0.0)
  @override
  final double avgTemp;

  @JsonKey(name: 'cadence', defaultValue: 0)
  @override
  final int cadence;

  @JsonKey(name: 'latest_label', defaultValue: '', fromJson: _parseLabel)
  @override
  final String latestLabel;

  @JsonKey(name: 'lbp_formula', fromJson: _parseString)
  @override
  final String lbpFormula;

  static String _parseLabel(dynamic value) => value?.toString() ?? '';
  static String _parseString(dynamic value) => value?.toString() ?? '';

  const TrackingSummaryModel({
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
  }) : super(
         totalMinWalk: totalMinWalk,
         totalTimeAlive: totalTimeAlive,
         posture: posture,
         lbpScore: lbpScore,
         totalSteps: totalSteps,
         avgHumidity: avgHumidity,
         avgPressure: avgPressure,
         avgTemp: avgTemp,
         cadence: cadence,
         latestLabel: latestLabel,
         lbpFormula: lbpFormula,
       );

  factory TrackingSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrackingSummaryModelToJson(this);

  @override
  TrackingSummary toEntity() => TrackingSummary(
    totalMinWalk: totalMinWalk,
    totalTimeAlive: totalTimeAlive,
    posture: posture,
    lbpScore: lbpScore,
    totalSteps: totalSteps,
    avgHumidity: avgHumidity,
    avgPressure: avgPressure,
    avgTemp: avgTemp,
    cadence: cadence,
    latestLabel: latestLabel,
    lbpFormula: lbpFormula,
  );

  factory TrackingSummaryModel.fromEntity(TrackingSummary entity) =>
      TrackingSummaryModel(
        totalMinWalk: entity.totalMinWalk,
        totalTimeAlive: entity.totalTimeAlive,
        posture: entity.posture,
        lbpScore: entity.lbpScore,
        totalSteps: entity.totalSteps,
        avgHumidity: entity.avgHumidity,
        avgPressure: entity.avgPressure,
        avgTemp: entity.avgTemp,
        cadence: entity.cadence,
        latestLabel: entity.latestLabel,
        lbpFormula: entity.lbpFormula,
      );

  TrackingSummaryModel copyWith({
    double? totalMinWalk,
    double? totalTimeAlive,
    double? posture,
    double? lbpScore,
    int? totalSteps,
    double? avgHumidity,
    double? avgPressure,
    double? avgTemp,
    int? cadence,
    String? latestLabel,
    String? lbpFormula,
  }) {
    return TrackingSummaryModel(
      totalMinWalk: totalMinWalk ?? this.totalMinWalk,
      totalTimeAlive: totalTimeAlive ?? this.totalTimeAlive,
      posture: posture ?? this.posture,
      lbpScore: lbpScore ?? this.lbpScore,
      totalSteps: totalSteps ?? this.totalSteps,
      avgHumidity: avgHumidity ?? this.avgHumidity,
      avgPressure: avgPressure ?? this.avgPressure,
      avgTemp: avgTemp ?? this.avgTemp,
      cadence: cadence ?? this.cadence,
      latestLabel: latestLabel ?? this.latestLabel,
      lbpFormula: lbpFormula ?? this.lbpFormula,
    );
  }
}
