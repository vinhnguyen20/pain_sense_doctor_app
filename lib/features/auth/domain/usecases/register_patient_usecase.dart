import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/auth/domain/entities/patient_registration.dart';
import 'package:app_doctor/features/auth/domain/repository/auth_repository.dart';

class RegisterPatientUseCase {
  final AuthRepository _repository;

  const RegisterPatientUseCase(this._repository);

  Future<ApiResponse<void>> call(PatientRegistration registration) {
    return _repository.registerPatient(registration);
  }
}
