import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/tracking/data/datasources/tracking_remote_datasource.dart';
import 'package:app_doctor/features/tracking/data/models/tracking_summary_item_model.dart';
import 'package:app_doctor/features/tracking/domain/repository/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingRemoteDataSource _dataSource;

  TrackingRepositoryImpl(this._dataSource);

  @override
  Future<ApiResponse<List<TrackingSummaryItemModel>>>
  getPatientTrackingSummary7Days({required String patientId}) async {
    try {
      final result = await _dataSource.getPatientTrackingSummary7Days(
        patientId: patientId,
      );
      return result;
    } catch (e, stackTrace) {
      return ApiResponse.failure(e, stackTrace);
    }
  }
}
