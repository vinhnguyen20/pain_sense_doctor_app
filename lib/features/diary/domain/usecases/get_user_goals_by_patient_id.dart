import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/domain/repository/diary_repository.dart';

class GetUserGoalsByPatientIdUseCase {
  final DiaryRepository _repository;
  GetUserGoalsByPatientIdUseCase(this._repository);

  Future<ApiResponse<PaginatedResponse<UserGoalModel>>> call({
    required String patientId,
    String? cursor,
    int? limit,
  }) {
    return _repository.getUserGoalsByPatientId(
      patientId: patientId,
      cursor: cursor,
      limit: limit,
    );
  }
}
