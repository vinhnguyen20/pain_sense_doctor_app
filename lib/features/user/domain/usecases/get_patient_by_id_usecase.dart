import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/domain/repository/user_repository.dart';

class GetPatientByIdUseCase {
  final UserRepository _userRepository;

  GetPatientByIdUseCase(this._userRepository);

  Future<ApiResponse<Patient?>> call(String patientId) async {
    return await _userRepository.getPatientById(patientId);
  }
}
