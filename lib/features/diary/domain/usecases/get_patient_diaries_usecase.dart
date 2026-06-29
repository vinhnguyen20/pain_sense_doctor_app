import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';

import '../../../../core/network/dio/api_response.dart';
import '../repository/diary_repository.dart';

class GetPatientDiariesUseCase {
  final DiaryRepository _repository;
  GetPatientDiariesUseCase(this._repository);

  Future<ApiResponse<PaginatedResponse<PatientDiaryEntry>>> call({
    String? cursor,
    int? limit,
    String? patientId,
  }) {
    return _repository.getPatientDiaries(
      cursor: cursor,
      limit: limit,
      patientId: patientId,
    );
  }
}
