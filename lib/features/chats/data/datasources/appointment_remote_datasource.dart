import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';

import '../../../../core/network/dio/api_response.dart';
import '../models/appointment_model.dart';

class AppointmentRemoteDataSource {
  final DioClient _client;

  AppointmentRemoteDataSource(this._client);

  Future<ApiResponse<PaginatedResponse<AppointmentModel>>> getAppointments({
    String? cursor,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cursor != null) queryParams['cursor'] = cursor;
      if (limit != null) queryParams['limit'] = limit;

      return await _client
          .get<ApiResponse<PaginatedResponse<AppointmentModel>>>(
            '/appointments/patient',
            queryParameters: queryParams,

            fromJson: (json) => ApiResponse.fromPaginatedJson<AppointmentModel>(
              json,
              (item) => AppointmentModel.fromJson(item as Map<String, dynamic>),
            ),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<PaginatedResponse<AppointmentModel>>>
  getAppointmentsByPatientId({
    required String patientId,
    String? cursor,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cursor != null) queryParams['cursor'] = cursor;
      if (limit != null) queryParams['limit'] = limit;
      return await _client
          .get<ApiResponse<PaginatedResponse<AppointmentModel>>>(
            '/appointments/patient/$patientId',
            queryParameters: queryParams,

            fromJson: (json) => ApiResponse.fromPaginatedJson<AppointmentModel>(
              json,
              (item) => AppointmentModel.fromJson(item as Map<String, dynamic>),
            ),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<AppointmentModel>> createAppointment(
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _client.post<ApiResponse<AppointmentModel>>(
        '/appointments/doctor',
        data: payload,
        fromJson: (json) => ApiResponse<AppointmentModel>.fromJson(
          json,
          (data) => AppointmentModel.fromJson(data),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<AppointmentModel>> getAppointmentById(
    String appointmentId,
  ) async {
    try {
      return await _client.get<ApiResponse<AppointmentModel>>(
        '/appointments/$appointmentId',

        fromJson: (json) => ApiResponse<AppointmentModel>.fromJson(
          json,
          (data) => AppointmentModel.fromJson(data),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<AppointmentModel>> updateAppointment(
    String appointmentId,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _client.put<ApiResponse<AppointmentModel>>(
        '/appointments/$appointmentId',
        data: payload,
        fromJson: (json) => ApiResponse<AppointmentModel>.fromJson(
          json,
          (data) => AppointmentModel.fromJson(data),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> deleteAppointment(String appointmentId) async {
    try {
      return await _client.delete<ApiResponse<void>>(
        '/appointments/$appointmentId',
        fromJson: (json) {
          if (json == null) {
            return const ApiResponse<void>(code: 0, message: 'Deleted');
          }
          return ApiResponse<void>.fromJson(json as Map<String, dynamic>, null);
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
