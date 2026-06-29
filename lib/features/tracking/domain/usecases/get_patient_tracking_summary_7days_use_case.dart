import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/tracking/data/models/tracking_summary_item_model.dart';
import 'package:app_doctor/features/tracking/domain/repository/tracking_repository.dart';

class GetPatientTrackingSummary7DaysUseCase {
  final TrackingRepository _repository;

  GetPatientTrackingSummary7DaysUseCase(this._repository);

  Future<ApiResponse<List<TrackingSummaryItemModel>>> call({
    required String patientId,
  }) {
    return _repository.getPatientTrackingSummary7Days(patientId: patientId);
  }
}
