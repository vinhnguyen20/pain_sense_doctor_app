import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/domain/entites/diary.dart';
import 'package:app_doctor/features/diary/domain/entites/diary_current_date.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';
import 'package:app_doctor/features/diary/domain/entites/user_goal_request.dart';

import '../../../../core/network/dio/api_response.dart';
import '../../domain/repository/diary_repository.dart';
import '../datasources/diary_remote_datasource.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryRemoteDataSource remoteDataSource;

  DiaryRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResponse<PaginatedResponse<Diary>>> getDiaries({
    String? cursor,
    int? limit,
    String? patientId,
  }) async {
    return await remoteDataSource.getDiaries(
      cursor: cursor,
      limit: limit,
      patientId: patientId,
    );
  }

  @override
  Future<ApiResponse<PaginatedResponse<PatientDiaryEntry>>> getPatientDiaries({
    String? cursor,
    int? limit,
    String? patientId,
  }) async {
    return await remoteDataSource.getPatientDiaries(
      cursor: cursor,
      limit: limit,
      patientId: patientId,
    );
  }

  @override
  Future<ApiResponse<void>> deleteUserGoal(String goalId) async {
    return await remoteDataSource.deleteUserGoal(goalId);
  }

  @override
  Future<ApiResponse<void>> updateUserGoal(UpdateUserGoalRequest request) {
    return remoteDataSource.updateUserGoal(request);
  }

  @override
  Future<ApiResponse<PaginatedResponse<UserGoalModel>>>
  getUserGoalsByPatientId({
    required String patientId,
    String? cursor,
    int? limit,
  }) async {
    return await remoteDataSource.getUserGoalsByPatientId(
      patientId: patientId,
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<ApiResponse<PaginatedResponse<PatientDiaryEntry>>>
  getUserGoalsByDoctor({String? cursor, int? limit}) async {
    return await remoteDataSource.getUserGoalsByDoctor(
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<ApiResponse<Diary>> getDiaryById(String diaryId) async {
    return await remoteDataSource.getDiaryById(diaryId);
  }

  @override
  Future<ApiResponse<Diary>> updateDiary(
    String diaryId, {
    String? note,
    String? comment,
  }) {
    return remoteDataSource.updateDiary(diaryId, note: note, comment: comment);
  }

  @override
  Future<ApiResponse<DiaryCurrentDate>> getDiaryCurrentDate() async {
    return await remoteDataSource.getDiaryCurrentDate();
  }

  @override
  Future<ApiResponse<void>> createUserGoalsWithExercises(
    CreateUserGoalWithExercisesRequest request,
  ) {
    return remoteDataSource.createUserGoalsWithExercises(request);
  }
}
