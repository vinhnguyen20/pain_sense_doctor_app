import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/domain/repository/appointment_repository.dart';

class GetAppointmentsUseCase {
  final AppointmentRepository _repository;

  GetAppointmentsUseCase(this._repository);

  Future<ApiResponse<PaginatedResponse<Appointment>>> call({
    String? cursor,
    int? limit,
  }) {
    return _repository.getAppointments(cursor: cursor, limit: limit);
  }
}
