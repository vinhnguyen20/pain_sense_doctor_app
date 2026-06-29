import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/diary/domain/entites/diary.dart';

import '../../../../core/network/dio/api_response.dart';
import '../repository/diary_repository.dart';

class GetDiariesUseCase {
  final DiaryRepository _repository;
  GetDiariesUseCase(this._repository);

  Future<ApiResponse<PaginatedResponse<Diary>>> call({
    String? cursor,
    int? limit,
    String? patientId,
  }) {
    return _repository.getDiaries(
      cursor: cursor,
      limit: limit,
      patientId: patientId,
    );
  }
}
