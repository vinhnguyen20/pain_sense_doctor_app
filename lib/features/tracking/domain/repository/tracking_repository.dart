import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/tracking/data/models/tracking_summary_item_model.dart';

abstract class TrackingRepository {
  Future<ApiResponse<List<TrackingSummaryItemModel>>>
  getPatientTrackingSummary7Days({required String patientId});
}
