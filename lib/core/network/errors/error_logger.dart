import 'dart:developer' as developer;
import 'package:app_doctor/core/network/errors/app_exception.dart';
import 'package:flutter/foundation.dart';

class ErrorLogger {
  static void log(AppException exception) {
    if (kDebugMode) {
      developer.log(
        exception.message,
        name: 'AppError',
        error: exception.originalError,
        stackTrace: exception.stackTrace,
      );
    }
  }
}
