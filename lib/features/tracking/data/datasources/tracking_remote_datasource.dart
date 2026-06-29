import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/features/tracking/data/models/tracking_summary_item_model.dart';

class TrackingRemoteDataSource {
  final DioClient _client;

  TrackingRemoteDataSource(this._client);

  Future<ApiResponse<List<TrackingSummaryItemModel>>>
  getPatientTrackingSummary7Days({required String patientId}) async {
    try {
      final result = await _client
          .get<ApiResponse<List<TrackingSummaryItemModel>>>(
            '/trackings/summary-patient-7-days/$patientId',

            fromJson: (json) {
              return ApiResponse<List<TrackingSummaryItemModel>>.fromJson(
                json,
                (data) => (data as List)
                    .map((item) => TrackingSummaryItemModel.fromJson(item))
                    .toList(),
              );
            },
          );
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
