import 'dart:convert';
import 'dart:typed_data';

import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/features/user/data/datasources/user_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('updates the signed-in doctor password', () async {
    final adapter = _JsonAdapter({'message': 'Password updated'});
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1'))
      ..httpClientAdapter = adapter;

    final response = await UserRemoteDataSource(
      DioClient(dio),
    ).updatePassword(oldPassword: 'old-password', newPassword: 'new-password');

    expect(adapter.request?.path, '/users/update-password');
    expect(adapter.request?.method, 'POST');
    expect(adapter.request?.data, {
      'old_password': 'old-password',
      'new_password': 'new-password',
    });
    expect(response.isSuccess, isTrue);
    expect(response.message, 'Password updated');
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
