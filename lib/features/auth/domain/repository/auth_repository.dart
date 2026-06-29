import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<ApiResponse<AuthToken>> signInWithEmailPassword(
    String email,
    String password,
  );
}
