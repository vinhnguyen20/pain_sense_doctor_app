import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/diary/data/models/diary_adherence_model.dart';
import 'package:app_doctor/features/tracking/domain/entites/tracking_summary_item.dart';
import 'package:json_annotation/json_annotation.dart';
import 'tracking_summary_model.dart';

part 'tracking_summary_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TrackingSummaryItemModel extends TrackingSummaryItem
    with EntityConvertible<TrackingSummaryItemModel, TrackingSummaryItem> {
  @JsonKey(name: 'log_date', fromJson: _parseDate)
  @override
  final DateTime logDate;

  @JsonKey(name: 'summary')
  @override
  final TrackingSummaryModel summary;

  @JsonKey(name: 'adherence')
  @override
  final PatientDiaryAdherenceModel? adherence;

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  const TrackingSummaryItemModel({
    required this.logDate,
    required this.summary,
    this.adherence,
  }) : super(logDate: logDate, summary: summary, adherence: adherence);

  factory TrackingSummaryItemModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingSummaryItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrackingSummaryItemModelToJson(this);

  @override
  TrackingSummaryItem toEntity() {
    return TrackingSummaryItem(
      logDate: logDate,
      summary: summary.toEntity(),
      adherence: adherence,
    );
  }

  factory TrackingSummaryItemModel.fromEntity(TrackingSummaryItem entity) {
    return TrackingSummaryItemModel(
      logDate: entity.logDate,
      summary: TrackingSummaryModel.fromEntity(entity.summary),
      adherence: entity.adherence,
    );
  }

  TrackingSummaryItemModel copyWith({
    DateTime? logDate,
    TrackingSummaryModel? summary,
    PatientDiaryAdherenceModel? adherence,
  }) {
    return TrackingSummaryItemModel(
      logDate: logDate ?? this.logDate,
      summary: summary ?? this.summary,
      adherence: adherence ?? this.adherence,
    );
  }
}
