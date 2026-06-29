import 'package:app_doctor/core/config/app_config.dart';
import 'package:app_doctor/core/constants/app_constants.dart';
import 'package:app_doctor/core/network/dio/dio_client.dart';
import 'package:app_doctor/core/network/dio/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final apiUrl = AppConfig.apiUrl;
  final dio = Dio(
    BaseOptions(
      baseUrl: apiUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );

  dio.interceptors.addAll([
    _MainApiGuardInterceptor(apiUrl),
    AuthInterceptor(ref),
    PrettyDioLogger(
      // requestHeader: true,
      requestBody: true,
      responseBody: true,
      // responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ),
  ]);

  ref.onDispose(() => dio.close());

  return dio;
}

@Riverpod(keepAlive: true)
DioClient dioClient(Ref ref) {
  return DioClient(ref.watch(dioProvider));
}

class _MainApiGuardInterceptor extends Interceptor {
  final String _mainApiUrl;

  _MainApiGuardInterceptor(this._mainApiUrl);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_mainApiUrl.isNotEmpty) {
      options.baseUrl = _mainApiUrl;
    }
    handler.next(options);
  }
}
