import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/chats/data/datasources/appointment_remote_datasource.dart';
import 'package:app_doctor/features/chats/domain/entites/appointment.dart';
import 'package:app_doctor/features/chats/domain/repository/appointment_repository.dart';

import '../../../../core/network/dio/api_response.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResponse<PaginatedResponse<Appointment>>> getAppointments({
    String? cursor,
    int? limit,
  }) async {
    return await remoteDataSource.getAppointments(cursor: cursor, limit: limit);
  }

  @override
  Future<ApiResponse<Appointment>> getAppointmentById(
    String appointmentId,
  ) async {
    return await remoteDataSource.getAppointmentById(appointmentId);
  }

  @override
  Future<ApiResponse<Appointment>> createAppointment(
    Map<String, dynamic> payload,
  ) async {
    return await remoteDataSource.createAppointment(payload);
  }

  @override
  Future<ApiResponse<PaginatedResponse<Appointment>>>
  getAppointmentsByPatientId({
    required String patientId,
    String? cursor,
    int? limit,
  }) async {
    return await remoteDataSource.getAppointmentsByPatientId(
      patientId: patientId,
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<ApiResponse<Appointment>> updateAppointment(
    String appointmentId,
    Map<String, dynamic> payload,
  ) async {
    return await remoteDataSource.updateAppointment(appointmentId, payload);
  }

  @override
  Future<ApiResponse<void>> deleteAppointment(String appointmentId) async {
    return await remoteDataSource.deleteAppointment(appointmentId);
  }
}
