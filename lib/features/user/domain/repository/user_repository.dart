import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';

abstract class UserRepository {
  Future<ApiResponse<User?>> getCurrentUser();
  Future<ApiResponse<User>> updateUser(User user);
  Future<ApiResponse<PaginatedResponse<Patient>>> getAllPatients({
    String? cursor,
    int? limit,
    String? search,
  });
}
