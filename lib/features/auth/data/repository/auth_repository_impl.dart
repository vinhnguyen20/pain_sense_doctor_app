import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_doctor/features/auth/domain/entities/user.dart';
import 'package:app_doctor/features/auth/domain/entities/patient_registration.dart';
import 'package:app_doctor/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<ApiResponse<void>> registerPatient(
    PatientRegistration registration,
  ) async {
    try {
      return await _dataSource.registerPatient(registration);
    } catch (error, stackTrace) {
      return ApiResponse.failure(error, stackTrace);
    }
  }

  @override
  Future<ApiResponse<AuthToken>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final res = await _dataSource.signInWithEmailPassword(email, password);
      if (res.data == null) {
        return ApiResponse(code: res.code, message: res.message);
      }
      return ApiResponse.success(res.data!.toEntity());
    } catch (e, stackTrace) {
      return ApiResponse.failure(e, stackTrace);
    }
  }
}
