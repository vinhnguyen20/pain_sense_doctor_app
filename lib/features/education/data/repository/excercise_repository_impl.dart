import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/education/data/datasources/exercise_remote_datasource.dart';
import 'package:app_doctor/features/education/domain/entites/exercise.dart';
import 'package:app_doctor/features/education/domain/entites/user_exercise.dart';
import 'package:app_doctor/features/education/domain/repository/exercise_repository.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseRemoteDataSource _remoteDataSource;

  ExerciseRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResponse<PaginatedResponse<Exercise>>> getExercises({
    String? level,
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _remoteDataSource.getExercises(
        level: level,
        cursor: cursor,
        limit: limit,
      );

      if (response.isSuccess && response.data != null) {
        final paginated = PaginatedResponse<Exercise>(
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
  Future<ApiResponse<Exercise>> getExerciseById(String id) async {
    try {
      final response = await _remoteDataSource.getExerciseById(id);

      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(response.data!.toEntity());
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
  Future<ApiResponse<PaginatedResponse<UserExercise>>> getUserExercises({
    String? status,
    String? cursor,
    int? limit,
  }) async {
    try {
      final response = await _remoteDataSource.getUserExercises(
        cursor: cursor,
        limit: limit,
      );

      if (response.isSuccess && response.data != null) {
        final paginated = PaginatedResponse<UserExercise>(
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
  Future<ApiResponse<UserExercise>> getUserExerciseById(String id) async {
    try {
      final response = await _remoteDataSource.getUserExerciseById(id);

      if (response.isSuccess && response.data != null) {
        return ApiResponse.success(response.data!.toEntity());
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
  Future<ApiResponse<void>> updateExerciseProgress({
    required String userExerciseId,
    required Map<String, dynamic> progress,
  }) async {
    try {
      return await _remoteDataSource.updateExerciseProgress(
        userExerciseId: userExerciseId,
        progress: progress,
      );
    } catch (e, stackTrace) {
      return ApiResponse.failure(e, stackTrace);
    }
  }
}
