import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/user/data/datasources/user_remote_datasource.dart';
import 'package:app_doctor/features/user/data/models/user_model.dart';
import 'package:app_doctor/features/user/domain/entities/patient.dart';
import 'package:app_doctor/features/user/domain/entities/user.dart';
import 'package:app_doctor/features/user/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<ApiResponse<User?>> getCurrentUser() async {
    try {
      final userModel = await _dataSource.getCurrentUser();
      return ApiResponse.success(userModel.data?.toEntity());
    } catch (e, stackTrace) {
      return ApiResponse.failure(e, stackTrace);
    }
  }

  @override
  Future<ApiResponse<PaginatedResponse<Patient>>> getAllPatients({
    String? cursor,
    int? limit,
    String? search,
  }) async {
    try {
      final response = await _dataSource.getAllPatients(
        cursor: cursor,
        limit: limit,
        search: search,
      );

      if (response.isSuccess && response.data != null) {
        final paginated = PaginatedResponse<Patient>(
          items: response.data!.items.map((model) => model.toEntity()).toList(),
          nextCursor: response.data!.nextCursor,
          limit: response.data!.limit,
        );
        return ApiResponse.success(paginated);
      }

      return ApiResponse(
        code: response.code,
        message: response.message,
        data: null,
      );
    } catch (e, stackTrace) {
      return ApiResponse.failure(e, stackTrace);
    }
  }

  @override
  Future<ApiResponse<User>> updateUser(User user) async {
    try {
      await _dataSource.updateUser(UserModel.fromEntity(user));
      return ApiResponse.success(UserModel.fromEntity(user));
    } catch (e, stackTrace) {
      return ApiResponse.failure(e, stackTrace);
    }
  }

}
