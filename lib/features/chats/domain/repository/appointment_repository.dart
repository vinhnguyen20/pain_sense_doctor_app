import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';

abstract class AppointmentRepository {
  Future<ApiResponse<PaginatedResponse<Appointment>>> getAppointments({
    String? cursor,
    int? limit,
  });
  Future<ApiResponse<Appointment>> createAppointment(
    Map<String, dynamic> payload,
  );
  Future<ApiResponse<Appointment>> getAppointmentById(String appointmentId);

  Future<ApiResponse<PaginatedResponse<Appointment>>>
  getAppointmentsByPatientId({
    required String patientId,
    String? cursor,
    int? limit,
  });

  Future<ApiResponse<Appointment>> updateAppointment(
    String appointmentId,
    Map<String, dynamic> payload,
  );

  Future<ApiResponse<void>> deleteAppointment(String appointmentId);
}
