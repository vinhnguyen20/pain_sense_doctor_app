import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/features/auth/data/models/user_model.dart';
import 'package:app_doctor/features/auth/domain/entities/patient_registration.dart';
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

  Future<ApiResponse<void>> updateDoctorProfile({
    required PatientProfileSetup profile,
    required String accessToken,
  }) async {
    return _client.put<ApiResponse<void>>(
      '/users/doctor',
      data: profile.toUpdateJson(DateTime.now()),
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      fromJson: (json) =>
          ApiResponse<void>.fromJson(json as Map<String, dynamic>, null),
    );
  }

  Future<ApiResponse<void>> updatePatientProfile({
    required PatientProfileSetup profile,
    required String accessToken,
  }) async {
    return updateDoctorProfile(profile: profile, accessToken: accessToken);
  }
}
