import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/domain/repository/appointment_repository.dart';

class GetAppointmentByIdUseCase {
  final AppointmentRepository _repository;

  GetAppointmentByIdUseCase(this._repository);

  Future<ApiResponse<Appointment>> call(String appointmentId) {
    return _repository.getAppointmentById(appointmentId);
  }
}
