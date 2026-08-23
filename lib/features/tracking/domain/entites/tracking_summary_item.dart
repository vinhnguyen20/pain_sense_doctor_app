import 'package:app_doctor/features/diary/data/models/diary_adherence_model.dart';
import 'package:equatable/equatable.dart';
import 'tracking_summary.dart';

class TrackingSummaryItem extends Equatable {
  final DateTime logDate;
  final TrackingSummary summary;
  final PatientDiaryAdherenceModel? adherence;

  const TrackingSummaryItem({
    required this.logDate,
    required this.summary,
    this.adherence,
  });

  @override
  List<Object?> get props => [logDate, summary, adherence];
}
