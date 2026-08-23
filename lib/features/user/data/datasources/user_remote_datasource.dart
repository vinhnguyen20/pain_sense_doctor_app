import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/user/data/models/patient_model.dart';
import 'package:app_doctor/features/user/data/models/user_model.dart';

class UserRemoteDataSource {
  final DioClient _client;

  UserRemoteDataSource(this._client);
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final result = await _client.get<ApiResponse<UserModel>>(
        '/users/info',

        fromJson: (json) {
          return ApiResponse<UserModel>.fromJson(
            json,
            (data) => UserModel.fromJson(data),
          );
        },
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<PaginatedResponse<PatientModel>>> getAllPatients({
    String? cursor,
    int? limit,
    String? search,
  }) async {
    try {
      final isSearching = search != null && search.trim().isNotEmpty;
      final endpoint = isSearching ? '/users/patients/search' : '/users/patients/all';
      
      final queryParams = <String, dynamic>{
        if (isSearching) 'q': search.trim(),
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
      };

      return await _client.get<ApiResponse<PaginatedResponse<PatientModel>>>(
        endpoint,
        queryParameters: queryParams,
        fromJson: (json) => ApiResponse.fromPaginatedJson<PatientModel>(
          json,
          (item) => PatientModel.fromJson(item as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<PatientModel>> getPatientById(String patientId) async {
    try {
      final normalizedId = patientId.trim();
      final result = await _client.get<ApiResponse<PatientModel>>(
        '/users/patient/$normalizedId',
        fromJson: (json) {
          return ApiResponse<PatientModel>.fromJson(
            json,
            (data) => PatientModel.fromJson(data as Map<String, dynamic>),
          );
        },
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<UserModel>> updateUser(UserModel user) async {
    try {
      final result = await _client.put<ApiResponse<UserModel>>(
        '/users/patient',
        data: user.toJson(),
        fromJson: (json) => ApiResponse<UserModel>.fromJson(
          json,
          (data) => UserModel.fromJson(data),
        ),
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
