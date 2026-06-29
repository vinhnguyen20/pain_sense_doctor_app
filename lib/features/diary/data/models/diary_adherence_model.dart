import 'package:json_annotation/json_annotation.dart';

part 'diary_adherence_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PatientDiaryAdherenceModel {
  @JsonKey(name: 'overall')
  final double overall;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'color')
  final String color;

  @JsonKey(name: 'by_type')
  final Map<String, ActivityAdherence> byType;

  const PatientDiaryAdherenceModel({
    required this.overall,
    required this.status,
    required this.color,
    required this.byType,
  });

  factory PatientDiaryAdherenceModel.fromJson(Map<String, dynamic> json) =>
      _$PatientDiaryAdherenceModelFromJson(json);

  Map<String, dynamic> toJson() => _$PatientDiaryAdherenceModelToJson(this);
}

@JsonSerializable()
class ActivityAdherence {
  @JsonKey(name: 'avg_percent')
  final double avgPercent;

  @JsonKey(name: 'total_days')
  final int totalDays;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'color')
  final String color;

  const ActivityAdherence({
    required this.avgPercent,
    required this.totalDays,
    required this.status,
    required this.color,
  });

  factory ActivityAdherence.fromJson(Map<String, dynamic> json) =>
      _$ActivityAdherenceFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityAdherenceToJson(this);
}
