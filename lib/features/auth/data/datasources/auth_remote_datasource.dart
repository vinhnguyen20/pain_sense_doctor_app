import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/features/auth/data/models/user_model.dart';
import 'package:app_doctor/features/auth/domain/entities/patient_registration.dart';
import 'package:app_doctor/features/user/data/models/user_model.dart' as user_models;
import 'package:dio/dio.dart';
import 'dart:async';

class AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSource({required DioClient client}) : _client = client;

  Future<ApiResponse<AuthTokenModel?>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _client.post<ApiResponse<AuthTokenModel>>(
        '/users/login',
        data: {'email': email, 'password': password},
        fromJson: (json) => ApiResponse<AuthTokenModel>.fromJson(
          json,
          (data) => AuthTokenModel.fromJson(data),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> registerDoctor(
    PatientRegistration registration,
  ) async {
    return _client.post<ApiResponse<void>>(
      '/users/doctor',
      data: registration.toJson(),
      fromJson: (json) =>
          ApiResponse<void>.fromJson(json as Map<String, dynamic>, null),
    );
  }

  Future<ApiResponse<void>> registerPatient(
    PatientRegistration registration,
  ) async {
    return registerDoctor(registration);
  }

  Future<ApiResponse<user_models.UserModel>> getCurrentUserInfo(
    String accessToken,
  ) async {
    return _client.get<ApiResponse<user_models.UserModel>>(
      '/users/info',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      fromJson: (json) => ApiResponse<user_models.UserModel>.fromJson(
        json,
        (data) => user_models.UserModel.fromJson(data as Map<String, dynamic>),
      ),
    );
  }

  Future<ApiResponse<void>> updateDoctorProfile({
    required String userId,
    required PatientProfileSetup profile,
    PatientRegistration? registration,
    required String accessToken,
  }) async {
    final normalizedId = userId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError('user_id path parameter is required in /users/{user_id}');
    }
    return _client.put<ApiResponse<void>>(
      '/users/$normalizedId',
      data: profile.toUpdateJson(DateTime.now(), registration: registration),
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      fromJson: (json) =>
          ApiResponse<void>.fromJson(json as Map<String, dynamic>, null),
    );
  }

  Future<ApiResponse<void>> updatePatientProfile({
    required String userId,
    required PatientProfileSetup profile,
    PatientRegistration? registration,
    required String accessToken,
  }) async {
    return updateDoctorProfile(
      userId: userId,
      profile: profile,
      registration: registration,
      accessToken: accessToken,
    );
  }
}
