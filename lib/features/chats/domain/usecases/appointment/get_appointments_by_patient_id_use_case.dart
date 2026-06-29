import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/domain/repository/appointment_repository.dart';

class GetAppointmentsByPatientIdUseCase {
  final AppointmentRepository _repository;

  GetAppointmentsByPatientIdUseCase(this._repository);

  Future<ApiResponse<PaginatedResponse<Appointment>>> call({
    required String patientId,
    String? cursor,
    int? limit,
  }) {
    return _repository.getAppointmentsByPatientId(
      patientId: patientId,
      cursor: cursor,
      limit: limit,
    );
  }
}
