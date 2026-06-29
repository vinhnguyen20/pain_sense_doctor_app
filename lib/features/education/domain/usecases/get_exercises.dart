import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/education/domain/entites/exercise.dart';
import 'package:app_doctor/features/education/domain/repository/exercise_repository.dart';

class GetExercisesUseCase {
  final ExerciseRepository _repository;

  GetExercisesUseCase(this._repository);

  Future<ApiResponse<PaginatedResponse<Exercise>>> call({
    String? level,
    String? cursor,
    int? limit,
  }) {
    return _repository.getExercises(level: level, cursor: cursor, limit: limit);
  }
}
