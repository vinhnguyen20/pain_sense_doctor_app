import 'package:app_doctor/common/widgets/app_snackbar.dart';
import 'package:app_doctor/core/network/dio/api_response.dart';
import 'package:app_doctor/core/network/errors/error_logger.dart';
import 'package:app_doctor/core/network/errors/exception_handler.dart';
import 'package:flutter/material.dart';

mixin ErrorHandlingMixin<T extends StatefulWidget> on State<T> {
  void handleError(dynamic error, [StackTrace? stackTrace]) {
    final exception = ExceptionHandler.handle(error, stackTrace);
    ErrorLogger.log(exception);

    if (mounted) {
      AppSnackbar.error(context, exception.message);
    }
  }

  Future<ApiResponse<R>> safeCall<R>(Future<R> Function() call) async {
    try {
      final result = await call();
      return ApiResponse.success(result);
    } catch (e, stackTrace) {
      final exception = ExceptionHandler.handle(e, stackTrace);
      ErrorLogger.log(exception);
      handleError(exception, stackTrace);
      return ApiResponse.failure(exception);
    }
  }
}
