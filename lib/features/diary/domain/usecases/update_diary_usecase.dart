import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/features/diary/domain/entites/diary.dart';
import 'package:app_doctor/features/diary/domain/repository/diary_repository.dart';

class UpdateDiaryUseCase {
  final DiaryRepository _repository;
  UpdateDiaryUseCase(this._repository);

  Future<ApiResponse<Diary>> call(
    String diaryId, {
    String? note,
    String? comment,
  }) {
    return _repository.updateDiary(diaryId, note: note, comment: comment);
  }
}
