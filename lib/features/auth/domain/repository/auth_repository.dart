import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/auth/domain/entities/user.dart';
import 'package:app_doctor/features/auth/domain/entities/patient_registration.dart';

abstract class AuthRepository {
  Future<ApiResponse<void>> registerPatient(PatientRegistration registration) {
    throw UnimplementedError('Patient registration is not implemented.');
  }

  Future<ApiResponse<AuthToken>> signInWithEmailPassword(
    String email,
    String password,
  );
}
