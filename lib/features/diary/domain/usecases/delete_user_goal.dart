import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/diary/domain/repository/diary_repository.dart';

class DeleteUserGoalUseCase {
  final DiaryRepository _repository;
  DeleteUserGoalUseCase(this._repository);

  Future<ApiResponse<void>> call(String goalId) {
    return _repository.deleteUserGoal(goalId);
  }
}
