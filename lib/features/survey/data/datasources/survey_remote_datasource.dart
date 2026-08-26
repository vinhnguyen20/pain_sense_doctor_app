import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/features/survey/data/models/survey_definition_model.dart';
import 'package:dio/dio.dart';

class SurveyRemoteDataSource {
  static const firstSurveyId = 'efb011a9-6601-4713-8c90-4123338bbf95';

  final DioClient _client;

  const SurveyRemoteDataSource(this._client);

  Future<ApiResponse<SurveyDefinitionModel>> getFirstSurvey() {
    return _client.get<ApiResponse<SurveyDefinitionModel>>(
      '/surveys/get_by_id/$firstSurveyId',
      fromJson: (json) => ApiResponse<SurveyDefinitionModel>.fromJson(
        json as Map<String, dynamic>,
        (data) => SurveyDefinitionModel.fromJson(
          Map<String, dynamic>.from(data as Map),
        ),
      ),
    );
  }

  Future<ApiResponse<void>> submitSurvey({
    required String surveyId,
    required List<UserSurveyResponseModel> responses,
    required DateTime startedAt,
    required String accessToken,
  }) {
    return _client.post<ApiResponse<void>>(
      '/user-surveys',
      data: {
        'survey_id': surveyId,
        'status': 'completed',
        'responses': responses.map((item) => item.toJson()).toList(),
        'started_at': startedAt.toUtc().toIso8601String(),
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      fromJson: (json) =>
          ApiResponse<void>.fromJson(json as Map<String, dynamic>, null),
    );
  }
}
