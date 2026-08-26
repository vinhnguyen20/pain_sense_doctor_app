import 'package:app_doctor/core/providers/dio_provider.dart';
import 'package:app_doctor/features/survey/data/datasources/survey_remote_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final surveyRemoteDataSourceProvider = Provider<SurveyRemoteDataSource>((ref) {
  return SurveyRemoteDataSource(ref.watch(dioClientProvider));
});
