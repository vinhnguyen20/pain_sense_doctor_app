import 'package:app_doctor/core/utils/entity_convertible.dart';
import 'package:app_doctor/features/tracking/domain/entites/tracking_summary_item.dart';
import 'package:json_annotation/json_annotation.dart';
import 'tracking_summary_model.dart';

part 'tracking_summary_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TrackingSummaryItemModel extends TrackingSummaryItem
    with EntityConvertible<TrackingSummaryItemModel, TrackingSummaryItem> {
  @JsonKey(name: 'log_date')
  @override
  final DateTime logDate;

  @JsonKey(name: 'summary')
  @override
  final TrackingSummaryModel summary;

  const TrackingSummaryItemModel({required this.logDate, required this.summary})
    : super(logDate: logDate, summary: summary);

  factory TrackingSummaryItemModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingSummaryItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrackingSummaryItemModelToJson(this);

  @override
  TrackingSummaryItem toEntity() {
    return TrackingSummaryItem(logDate: logDate, summary: summary.toEntity());
  }

  factory TrackingSummaryItemModel.fromEntity(TrackingSummaryItem entity) {
    return TrackingSummaryItemModel(
      logDate: entity.logDate,
      summary: TrackingSummaryModel.fromEntity(entity.summary),
    );
  }

  TrackingSummaryItemModel copyWith({
    DateTime? logDate,
    TrackingSummaryModel? summary,
  }) {
    return TrackingSummaryItemModel(
      logDate: logDate ?? this.logDate,
      summary: summary ?? this.summary,
    );
  }
}
