import 'package:equatable/equatable.dart';
import 'tracking_summary.dart';

class TrackingSummaryItem extends Equatable {
  final DateTime logDate;
  final TrackingSummary summary;

  const TrackingSummaryItem({required this.logDate, required this.summary});

  @override
  List<Object?> get props => [logDate, summary];
}
