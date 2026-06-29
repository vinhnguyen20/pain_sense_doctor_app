import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/education/domain/entites/user_exercise.dart';
import 'package:app_doctor/features/education/domain/repository/exercise_repository.dart';

class GetUserExercisesUseCase {
  final ExerciseRepository _repository;

  GetUserExercisesUseCase(this._repository);

  Future<ApiResponse<PaginatedResponse<UserExercise>>> call({
    String? level,
    String? cursor,
    int? limit,
  }) {
    return _repository.getUserExercises(cursor: cursor, limit: limit);
  }
}
