import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/education/data/models/exercise_model.dart';
import 'package:app_doctor/features/education/data/models/user_exercise_model.dart';
import 'package:flutter/foundation.dart';

class ExerciseRemoteDataSource {
  final DioClient _client;

  ExerciseRemoteDataSource(this._client);

  Future<ApiResponse<PaginatedResponse<ExerciseModel>>> getExercises({
    String? level,
    String? cursor,
    int? limit,
  }) async {
    try {
      return await _client.get<ApiResponse<PaginatedResponse<ExerciseModel>>>(
        '/exercises',
        queryParameters: {
          if (level != null) 'level': level,
          if (cursor != null) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
        fromJson: (json) => ApiResponse.fromPaginatedJson<ExerciseModel>(
          json,
          (item) => ExerciseModel.fromJson(item as Map<String, dynamic>),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('getExercises error: $stackTrace');
      return ApiResponse.failure(e, stackTrace);
    }
  }

  Future<ApiResponse<PaginatedResponse<UserExerciseModel>>> getUserExercises({
    String? cursor,
    int? limit,
  }) async {
    try {
      return await _client
          .get<ApiResponse<PaginatedResponse<UserExerciseModel>>>(
            '/user-exercises/user',
            queryParameters: {
              if (cursor != null) 'cursor': cursor,
              if (limit != null) 'limit': limit,
            },

            fromJson: (json) =>
                ApiResponse.fromPaginatedJson<UserExerciseModel>(
                  json,
                  (item) =>
                      UserExerciseModel.fromJson(item as Map<String, dynamic>),
                ),
          );
    } catch (e, stackTrace) {
      debugPrint('getUserExercises error: $stackTrace');
      return ApiResponse.failure(e, stackTrace);
    }
  }

  Future<ApiResponse<ExerciseModel>> getExerciseById(String id) async {
    return await _client.get(
      '/exercises/$id',
      fromJson: (json) => ApiResponse<ExerciseModel>.fromJson(json, (data) {
        final item = (data is List) ? data.first : data;
        return ExerciseModel.fromJson(item as Map<String, dynamic>);
      }),
    );
  }

  Future<ApiResponse<UserExerciseModel>> getUserExerciseById(String id) async {
    try {
      return await _client.get(
        '/user-exercises/$id',

        fromJson: (json) => ApiResponse<UserExerciseModel>.fromJson(
          json,
          (data) => UserExerciseModel.fromJson(data),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> updateExerciseProgress({
    required String userExerciseId,
    required Map<String, dynamic> progress,
  }) async {
    try {
      return await _client.put(
        '/user-exercises/$userExerciseId/progress',
        data: progress,
        fromJson: (json) => _toVoidApiResponse(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  ApiResponse<void> _toVoidApiResponse(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ApiResponse<void>(
        code: 0,
        message: json['message'] as String? ?? 'Success',
      );
    }
    return const ApiResponse<void>(code: 0, message: 'Success');
  }
}
