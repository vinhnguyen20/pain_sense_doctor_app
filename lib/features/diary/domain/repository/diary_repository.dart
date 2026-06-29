import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/domain/entites/diary.dart';
import 'package:app_doctor/features/diary/domain/entites/diary_current_date.dart';
import 'package:app_doctor/features/diary/domain/entites/patient_diary_entry.dart';
import 'package:app_doctor/features/diary/domain/entites/user_goal_request.dart';

import '../../../../core/network/dio/api_response.dart';

abstract class DiaryRepository {
  Future<ApiResponse<PaginatedResponse<Diary>>> getDiaries({
    String? cursor,
    int? limit,
    String? patientId,
  });

  Future<ApiResponse<PaginatedResponse<PatientDiaryEntry>>> getPatientDiaries({
    String? cursor,
    int? limit,
    String? patientId,
  });

  Future<ApiResponse<PaginatedResponse<PatientDiaryEntry>>>
  getUserGoalsByDoctor({String? cursor, int? limit});
  Future<ApiResponse<Diary>> getDiaryById(String diaryId);

  Future<ApiResponse<Diary>> updateDiary(
    String diaryId, {
    String? note,
    String? comment,
  });
  Future<ApiResponse<DiaryCurrentDate>> getDiaryCurrentDate();

  Future<ApiResponse<void>> createUserGoalsWithExercises(
    CreateUserGoalWithExercisesRequest request,
  );

  Future<ApiResponse<PaginatedResponse<UserGoalModel>>>
  getUserGoalsByPatientId({
    required String patientId,
    String? cursor,
    int? limit,
  });
  Future<ApiResponse<void>> deleteUserGoal(String goalId);
  Future<ApiResponse<void>> updateUserGoal(UpdateUserGoalRequest request);
}
