import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/domain/repository/appointment_repository.dart';

class CreateAppointmentUseCase {
  final AppointmentRepository _repository;

  CreateAppointmentUseCase(this._repository);

  Future<ApiResponse<Appointment>> call(Map<String, dynamic> payload) {
    return _repository.createAppointment(payload);
  }
}
