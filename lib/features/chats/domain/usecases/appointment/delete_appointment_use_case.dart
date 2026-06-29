import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/chats/domain/repository/appointment_repository.dart';

class DeleteAppointmentUseCase {
  final AppointmentRepository _repository;

  DeleteAppointmentUseCase(this._repository);

  Future<ApiResponse<void>> call(String appointmentId) {
    return _repository.deleteAppointment(appointmentId);
  }
}
