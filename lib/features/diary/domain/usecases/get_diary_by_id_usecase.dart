import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/diary/domain/entites/diary.dart';
import 'package:app_doctor/features/diary/domain/repository/diary_repository.dart';

class GetDiaryByIdUseCase {
  final DiaryRepository _repository;
  GetDiaryByIdUseCase(this._repository);

  Future<ApiResponse<Diary>> call(String diaryId) {
    return _repository.getDiaryById(diaryId);
  }
}
