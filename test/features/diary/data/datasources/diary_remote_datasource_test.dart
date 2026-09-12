import 'dart:convert';
import 'dart:typed_data';

import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/features/diary/data/datasources/diary_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads diary progress with the visible date range', () async {
    final adapter = _SequenceJsonAdapter([
      _progressResponse(progress: 0, diaries: const []),
      _progressResponse(
        progress: 42.5,
        diaries: const [
          {'date': '2026-09-12', 'diary': []},
        ],
      ),
    ]);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
      ..httpClientAdapter = adapter;

    final response = await DiaryRemoteDataSource(DioClient(dio))
        .getDiaryProgress(
          patientId: 'patient-1',
          fromDate: '2026-09-06',
          toDate: '2026-09-12',
        );

    expect(response.isSuccess, isTrue);
    expect(response.data?.progressScore, 42.5);
    expect(adapter.requests.map((request) => request.path), [
      '/diary/patient',
      '/diary/by_patient_id/patient-1',
    ]);
    expect(adapter.requests.first.queryParameters, {
      'limit': 10,
      'from_date': '2026-09-06',
      'to_date': '2026-09-12',
    });
  });
}

Map<String, dynamic> _progressResponse({
  required double progress,
  required List<Map<String, dynamic>> diaries,
}) => {
  'message': 'success',
  'data': {
    'items': {
      'diaries': diaries,
      'progress_score': progress,
      'components': <String, dynamic>{},
    },
    'next_cursor': '',
    'limit': 10,
  },
};

class _SequenceJsonAdapter implements HttpClientAdapter {
  final List<Object> responses;
  final List<RequestOptions> requests = [];

  _SequenceJsonAdapter(this.responses);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final response = responses[requests.length - 1];
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
