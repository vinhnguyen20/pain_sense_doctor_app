import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/education/domain/entites/exercise.dart';
import 'package:app_doctor/features/education/domain/entites/user_exercise.dart';

abstract class ExerciseRepository {
  Future<ApiResponse<PaginatedResponse<Exercise>>> getExercises({
    String? level,
    String? cursor,
    int? limit,
  });

  Future<ApiResponse<Exercise>> getExerciseById(String id);

  Future<ApiResponse<PaginatedResponse<UserExercise>>> getUserExercises({
    String? status,
    String? cursor,
    int? limit,
  });

  Future<ApiResponse<UserExercise>> getUserExerciseById(String id);

  Future<ApiResponse<void>> updateExerciseProgress({
    required String userExerciseId,
    required Map<String, dynamic> progress,
  });
}
