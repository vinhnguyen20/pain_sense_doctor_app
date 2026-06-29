import 'dart:async';
import 'package:app_doctor/core/services/auth/token_service.dart';
import 'package:app_doctor/features/auth/presentation/provider/auth_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;

  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  static const _refreshPath = '/users/refresh';

  AuthInterceptor(this.ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isRefreshRequest(options.path)) {
      return handler.next(options);
    }

    final token = await ref
        .read(tokenServiceProvider.notifier)
        .getAccessToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (_isRefreshRequest(err.requestOptions.path)) {
      _forceLogout();
      return handler.next(err);
    }

    try {
      final newToken = await _doRefresh(err.requestOptions);

      if (newToken == null) {
        debugPrint('AuthInterceptor: no new token after refresh, force logout');
        _forceLogout();
        return handler.next(err);
      }

      final retryResponse = await _retryRequest(
        err.requestOptions,
        newToken,
      );

      if (retryResponse.statusCode == 401) {
        _forceLogout();
        return handler.next(err);
      }

      return handler.resolve(retryResponse);
    } catch (e) {
      debugPrint('AuthInterceptor: exception during refresh - $e');
      _forceLogout();
      return handler.next(err);
    }
  }

  Future<String?> _doRefresh(RequestOptions original) async {
    if (_isRefreshing) {
      debugPrint('AuthInterceptor: refresh in progress, waiting...');
      return _refreshCompleter?.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await ref
          .read(tokenServiceProvider.notifier)
          .getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('AuthInterceptor: no refresh token in storage');
        _refreshCompleter?.complete(null);
        return null;
      }

      final plainDio = Dio(BaseOptions(baseUrl: original.baseUrl));
      final response = await plainDio.post(
        _refreshPath,
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'] as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await ref
            .read(tokenServiceProvider.notifier)
            .updateAccessToken(newAccessToken);

        debugPrint('AuthInterceptor: token refreshed successfully');
        _refreshCompleter?.complete(newAccessToken);
        return newAccessToken;
      }

      debugPrint('AuthInterceptor: refresh response missing accessToken');
      _refreshCompleter?.complete(null);
      return null;
    } catch (e) {
      debugPrint('AuthInterceptor: refresh request failed - $e');
      _refreshCompleter?.complete(null);
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String newToken,
  ) {
    final plainDio = Dio(BaseOptions(baseUrl: requestOptions.baseUrl));

    return plainDio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: {
          ...requestOptions.headers,
          'Authorization': 'Bearer $newToken',
        },
      ),
    );
  }

  void _forceLogout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).forceLogout();
    });
  }

  bool _isRefreshRequest(String path) => path.contains(_refreshPath);
}