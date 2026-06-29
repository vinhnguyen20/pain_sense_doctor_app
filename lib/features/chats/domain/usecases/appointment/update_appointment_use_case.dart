import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/domain/repository/appointment_repository.dart';

class UpdateAppointmentUseCase {
  final AppointmentRepository _repository;

  UpdateAppointmentUseCase(this._repository);

  Future<ApiResponse<Appointment>> call(
    String appointmentId,
    Map<String, dynamic> payload,
  ) {
    return _repository.updateAppointment(appointmentId, payload);
  }
}
