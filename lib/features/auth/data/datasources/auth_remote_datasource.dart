import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/features/auth/data/models/user_model.dart';
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
}
