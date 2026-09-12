import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/features/diary/data/models/diary_adherence_model.dart';
import 'package:app_doctor/features/diary/data/models/diary_current_date_model.dart';
import 'package:app_doctor/features/diary/data/models/patient_diary_entry_model.dart';
import 'package:app_doctor/features/diary/data/models/user_goal_model.dart';
import 'package:app_doctor/features/diary/domain/entites/diary_current_date.dart';
import 'package:app_doctor/features/diary/domain/entites/user_goal_request.dart';
import '../../../../core/network/dio/api_response.dart';
import '../models/diary_model.dart';

class DiaryProgressSnapshot {
  final double progressScore;
  final int diaryCount;

  const DiaryProgressSnapshot({
    required this.progressScore,
    required this.diaryCount,
  });

  factory DiaryProgressSnapshot.fromJson(dynamic data) {
    final dataMap = data is Map
        ? Map<String, dynamic>.from(data)
        : const <String, dynamic>{};
    final rawItems = dataMap['items'];
    final items = rawItems is Map
        ? Map<String, dynamic>.from(rawItems)
        : const <String, dynamic>{};
    final rawDiaries = items['diaries'];
    final score = items['progress_score'];
    return DiaryProgressSnapshot(
      progressScore: score is num
          ? score.toDouble()
          : double.tryParse(score?.toString() ?? '') ?? 0,
      diaryCount: rawDiaries is List ? rawDiaries.length : 0,
    );
  }
}

class DiaryRemoteDataSource {
  final DioClient _client;

  DiaryRemoteDataSource(this._client);

  Future<ApiResponse<DiaryProgressSnapshot>> getDiaryProgress({
    required String patientId,
    required String fromDate,
    required String toDate,
    int limit = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'limit': limit,
      'from_date': fromDate,
      'to_date': toDate,
    };

    ApiResponse<DiaryProgressSnapshot> parse(dynamic json) =>
        ApiResponse<DiaryProgressSnapshot>.fromJson(
          json as Map<String, dynamic>,
          DiaryProgressSnapshot.fromJson,
        );

    try {
      final currentUserResponse = await _client
          .get<ApiResponse<DiaryProgressSnapshot>>(
            '/diary/patient',
            queryParameters: queryParameters,
            fromJson: parse,
          );

      // /diary/patient is the requested endpoint. A doctor token has no own
      // diary, so use the patient-id variant only when it returns no entries.
      final normalizedPatientId = patientId.trim();
      if ((currentUserResponse.data?.diaryCount ?? 0) > 0 ||
          normalizedPatientId.isEmpty) {
        return currentUserResponse;
      }

      return await _client.get<ApiResponse<DiaryProgressSnapshot>>(
        '/diary/by_patient_id/$normalizedPatientId',
        queryParameters: queryParameters,
        fromJson: parse,
      );
    } catch (error, stackTrace) {
      return ApiResponse.failure(error, stackTrace);
    }
  }

  Future<ApiResponse<PaginatedResponse<DiaryModel>>> getDiaries({
    String? cursor,
    int? limit,
    String? patientId,
  }) async {
    try {
      final normalizedPatientId = patientId?.trim();
      if (normalizedPatientId == null || normalizedPatientId.isEmpty) {
        throw ArgumentError('patientId is required for getDiaries');
      }

      final queryParams = <String, dynamic>{};
      if (cursor != null) queryParams['cursor'] = cursor;
      if (limit != null) queryParams['limit'] = limit;

      return await _client.get<ApiResponse<PaginatedResponse<DiaryModel>>>(
        '/diary/by_patient_id/$normalizedPatientId',
        queryParameters: queryParams,

        fromJson: (json) => ApiResponse.fromPaginatedJson<DiaryModel>(
          json,
          (item) => DiaryModel.fromJson(item as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> createUserGoalsWithExercises(
    CreateUserGoalWithExercisesRequest request,
  ) async {
    try {
      return await _client.post<ApiResponse<void>>(
        '/user-goals/exercise-with-goal',
        data: request.toJson(),
        fromJson: (json) => ApiResponse.fromJson(json, (_) {}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<DiaryCurrentDate>> getDiaryCurrentDate() async {
    try {
      return await _client.get<ApiResponse<DiaryCurrentDate>>(
        '/diary/patient/current_date',

        fromJson: (json) {
          final list = json['data'] as List;
          final data = list.isNotEmpty
              ? DiaryCurrentDateModel.fromJson(list[0] as Map<String, dynamic>)
              : null;
          return ApiResponse(
            message: json['message'] as String,
            data: data,
            code: 0,
          );
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<PaginatedResponse<PatientDiaryEntryModel>>>
  getPatientDiaries({String? cursor, int? limit, String? patientId}) async {
    try {
      final normalizedPatientId = patientId?.trim();
      if (normalizedPatientId == null || normalizedPatientId.isEmpty) {
        throw ArgumentError('patientId is required for getPatientDiaries');
      }

      final queryParams = <String, dynamic>{};
      if (cursor != null) queryParams['cursor'] = cursor;
      if (limit != null) queryParams['limit'] = limit;
      final endpoint = '/diary/by_patient_id/$normalizedPatientId';

      return await _client
          .get<ApiResponse<PaginatedResponse<PatientDiaryEntryModel>>>(
            endpoint,
            queryParameters: queryParams,

            fromJson: (json) =>
                ApiResponse.fromPaginatedJson<PatientDiaryEntryModel>(
                  json,
                  (item) => PatientDiaryEntryModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                ),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<PaginatedResponse<PatientDiaryEntryModel>>>
  getUserGoalsByDoctor({String? cursor, int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cursor != null) queryParams['cursor'] = cursor;
      if (limit != null) queryParams['limit'] = limit;

      return await _client
          .get<ApiResponse<PaginatedResponse<PatientDiaryEntryModel>>>(
            '/user-goals/doctor',
            queryParameters: queryParams,
            fromJson: (json) =>
                ApiResponse.fromPaginatedJson<PatientDiaryEntryModel>(
                  json,
                  (item) => PatientDiaryEntryModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                ),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<PaginatedResponse<UserGoalModel>>>
  getUserGoalsByPatientId({
    required String patientId,
    String? cursor,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cursor != null) queryParams['cursor'] = cursor;
      if (limit != null) queryParams['limit'] = limit;

      return await _client.get<ApiResponse<PaginatedResponse<UserGoalModel>>>(
        '/user-goals/doctor/$patientId',
        queryParameters: queryParams,
        fromJson: (json) => ApiResponse.fromPaginatedJson<UserGoalModel>(
          json,
          (item) => UserGoalModel.fromJson(item as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> deleteUserGoal(String goalId) async {
    try {
      return await _client.delete<ApiResponse<void>>(
        '/user-goals/$goalId',
        fromJson: (json) => ApiResponse.fromJson(json, (_) {}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<void>> updateUserGoal(
    UpdateUserGoalRequest request,
  ) async {
    try {
      return await _client.put<ApiResponse<void>>(
        '/user-goals/bulk-upsert/${request.compositeId}',
        data: request.toJson(),
        fromJson: (json) => ApiResponse.fromJson(json, (_) {}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<PatientDiaryAdherenceModel>> getDiaryAdherenceRate(
    String patientId,
  ) async {
    try {
      final normalizedPatientId = patientId.trim();
      if (normalizedPatientId.isEmpty) {
        throw ArgumentError('patientId is required for getDiaryAdherenceRate');
      }

      return await _client.get<ApiResponse<PatientDiaryAdherenceModel>>(
        '/diary/patient/get_adherence_rate/$normalizedPatientId',

        fromJson: (json) => ApiResponse.fromJson(
          json,
          (data) =>
              PatientDiaryAdherenceModel.fromJson(data as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<DiaryModel>> getDiaryById(String diaryId) async {
    try {
      return await _client.get<ApiResponse<DiaryModel>>(
        '/diaries/$diaryId',

        fromJson: (json) => ApiResponse<DiaryModel>.fromJson(
          json,
          (data) => DiaryModel.fromJson(data),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<DiaryModel>> updateDiary(
    String diaryId, {
    String? note,
    String? comment,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (note != null) body['note'] = note;
      if (comment != null) body['comment'] = comment;

      return await _client.put<ApiResponse<DiaryModel>>(
        '/diary/$diaryId',
        data: body,
        fromJson: (json) => ApiResponse<DiaryModel>.fromJson(
          json,
          (data) => DiaryModel.fromJson(data),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
