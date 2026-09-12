import 'dart:convert';
import 'dart:typed_data';

import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/features/education/data/datasources/exercise_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'patient/date exercises accept schedules without exercise_date',
    () async {
      final adapter = _JsonAdapter({
        'message': 'success',
        'data': {
          'items': [
            {
              'id': 'assignment-1',
              'user_id': 'patient-1',
              'exercise_id': 'exercise-1',
              'assigned_date': '2026-09-05',
              'start_date': '2026-09-05T00:00:00Z',
              'end_date': '2026-09-30T00:00:00Z',
              'schedule_config': [
                {
                  'slots': [
                    {'period': 'anytime', 'time': '', 'is_completed': false},
                  ],
                  'sessions_count': 0,
                  'sessions_completed': 0,
                  'sessions_total': 1,
                },
              ],
              'status': 'inactive',
              'summary': {
                'total_sessions_completed': 0,
                'compliance_rate': 0.0,
              },
              'data_exercise': {'id': 'exercise-1', 'title': 'Video bài tập 2'},
            },
          ],
          'limit': 100,
          'next_cursor': '',
        },
      });
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
        ..httpClientAdapter = adapter;

      final response = await ExerciseRemoteDataSource(DioClient(dio))
          .getUserExercisesByPatientDate(
            patientId: 'patient-1',
            currentDate: '2026-09-12',
            limit: 100,
          );

      expect(response.isSuccess, isTrue);
    expect(
      adapter.request?.path,
      '/user-exercises/patient/patient-1/2026-09-12',
    );
      expect(adapter.request?.queryParameters, {'limit': 100});
      expect(
        response.data?.items.single.dataExercise?.title,
        'Video bài tập 2',
      );
      expect(
        response.data?.items.single.scheduleConfig.single.exerciseDate,
        DateTime(2026, 9, 12),
      );
    },
  );
}

class _JsonAdapter implements HttpClientAdapter {
  final Object responseJson;
  RequestOptions? request;

  _JsonAdapter(this.responseJson);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode(responseJson),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
