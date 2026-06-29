import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/diary/domain/entites/user_goal_request.dart';
import 'package:app_doctor/features/diary/domain/repository/diary_repository.dart';

class UpdateUserGoalUseCase {
  final DiaryRepository _repository;
  UpdateUserGoalUseCase(this._repository);

  Future<ApiResponse<void>> call(UpdateUserGoalRequest request) {
    return _repository.updateUserGoal(request);
  }
}
