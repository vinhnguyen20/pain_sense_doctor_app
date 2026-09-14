import 'dart:convert';
import 'dart:typed_data';

import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/features/chats/data/datasources/appointment_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads the doctor upcoming appointments with pagination', () async {
    final adapter = _JsonAdapter({
      'message': 'success',
      'data': {
        'items': [
          {
            'id': 'appointment-1',
            'title': 'Follow-up',
            'description': 'Weekly review',
            'patient_name': 'Bella Vu',
            'doctor_name': 'Doctor Test',
            'created_by': 'doctor-1',
            'type': 'video_call',
            'status': 'confirmed',
            'meeting_link': null,
            'is_sent': true,
            'schedule': {
              'date': '2026-09-15',
              'start_time': '14:00',
              'end_time': '14:30',
              'timezone': 'Asia/Ho_Chi_Minh',
            },
            'meeting_meta': null,
            'created_at': '2026-09-14T08:00:00Z',
          },
        ],
        'next_cursor': 'appointment-1_2026-09-15_14:00',
        'limit': 2,
      },
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
      ..httpClientAdapter = adapter;

    final response = await AppointmentRemoteDataSource(
      DioClient(dio),
    ).getAppointments(cursor: 'previous-cursor', limit: 2);

    expect(adapter.request?.path, '/appointments/doctor/upcoming');
    expect(adapter.request?.queryParameters, {
      'cursor': 'previous-cursor',
      'limit': 2,
    });
    expect(response.data?.items.single.patientName, 'Bella Vu');
    expect(response.data?.items.single.patientId, isEmpty);
    expect(response.data?.items.single.doctorId, isEmpty);
    expect(response.data?.nextCursor, 'appointment-1_2026-09-15_14:00');
  });
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
