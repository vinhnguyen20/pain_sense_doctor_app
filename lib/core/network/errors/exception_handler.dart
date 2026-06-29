import 'dart:async';
import 'dart:io';

import 'package:app_doctor/core/network/errors/app_exception.dart';
import 'package:dio/dio.dart';

class ExceptionHandler {
  static AppException handle(dynamic error, [StackTrace? stackTrace]) {
    if (error is ThrowException) {
      return AppException(
        error.toString(),
        code: error.errorCode.code,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error, stackTrace);
    }

    if (error is SocketException) {
      return _handleSocketError(error, stackTrace);
    }

    if (error is HttpException) {
      return _handleHttpError(error, stackTrace);
    }

    if (error is FormatException) {
      return _handleFormatError(error, stackTrace);
    }

    if (error is TimeoutException) {
      return _handleTimeoutError(error, stackTrace);
    }

    if (error is ArgumentError) {
      return _handleArgumentError(error, stackTrace);
    }

    if (error is StateError) {
      return _handleStateError(error, stackTrace);
    }

    if (error is RangeError) {
      return _handleRangeError(error, stackTrace);
    }

    if (error is TypeError) {
      return _handleTypeError(error, stackTrace);
    }

    if (error is NoSuchMethodError) {
      return _handleNoSuchMethodError(error, stackTrace);
    }

    if (error is UnsupportedError) {
      return _handleUnsupportedError(error, stackTrace);
    }

    if (error is ConcurrentModificationError) {
      return _handleConcurrentModificationError(error, stackTrace);
    }

    if (error is OutOfMemoryError) {
      return _handleOutOfMemoryError(error, stackTrace);
    }

    if (error is StackOverflowError) {
      return _handleStackOverflowError(error, stackTrace);
    }

    return AppException(
      'Unhandled exception: ${error.toString()}',
      code: ErrorCode.unknown.code,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  // Network Errors (Dio)
  static AppException _handleDioError(DioException e, StackTrace? stackTrace) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException(
          ErrorCode.connectionTimeout.message,
          code: ErrorCode.connectionTimeout.code,
          originalError: e,
          stackTrace: stackTrace,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? -1;
        final responseData = e.response?.data;
        final serverMessage = (responseData is Map<String, dynamic>)
            ? (responseData['message'] as String?) ??
                  (responseData['error'] as String?)
            : null;

        return AppException(
          serverMessage ?? 'HTTP Error: $statusCode',
          code: statusCode,
          originalError: e,
          stackTrace: stackTrace,
        );

      case DioExceptionType.cancel:
        return AppException(
          'Request cancelled',
          code: ErrorCode.unknown.code,
          originalError: e,
          stackTrace: stackTrace,
        );

      case DioExceptionType.connectionError:
        return AppException(
          ErrorCode.noInternetConnection.message,
          code: ErrorCode.noInternetConnection.code,
          originalError: e,
          stackTrace: stackTrace,
        );

      default:
        return AppException(
          ErrorCode.networkError.message,
          code: ErrorCode.networkError.code,
          originalError: e,
          stackTrace: stackTrace,
        );
    }
  }

  // Socket Errors
  static AppException _handleSocketError(
    SocketException e,
    StackTrace? stackTrace,
  ) {
    return AppException(
      ErrorCode.noInternetConnection.message,
      code: ErrorCode.noInternetConnection.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // HTTP Errors
  static AppException _handleHttpError(
    HttpException e,
    StackTrace? stackTrace,
  ) {
    return AppException(
      ErrorCode.networkError.message,
      code: ErrorCode.networkError.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // Format Errors
  static AppException _handleFormatError(
    FormatException e,
    StackTrace? stackTrace,
  ) {
    return AppException(
      'Invalid data format: ${e.message}',
      code: ErrorCode.invalidFormat.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // Timeout Errors
  static AppException _handleTimeoutError(
    TimeoutException e,
    StackTrace? stackTrace,
  ) {
    return AppException(
      ErrorCode.connectionTimeout.message,
      code: ErrorCode.connectionTimeout.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // Argument Errors
  static AppException _handleArgumentError(
    ArgumentError e,
    StackTrace? stackTrace,
  ) {
    return AppException(
      'Invalid argument: ${e.message}',
      code: ErrorCode.validationFailed.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // State Errors
  static AppException _handleStateError(StateError e, StackTrace? stackTrace) {
    return AppException(
      'Invalid state: ${e.message}',
      code: ErrorCode.unknown.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // Range Errors
  static AppException _handleRangeError(RangeError e, StackTrace? stackTrace) {
    return AppException(
      'Range error: ${e.message}',
      code: ErrorCode.validationFailed.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // Type Errors
  static AppException _handleTypeError(TypeError e, StackTrace? stackTrace) {
    return AppException(
      'Type error: ${e.toString()}',
      code: ErrorCode.unknown.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // NoSuchMethod Errors
  static AppException _handleNoSuchMethodError(
    NoSuchMethodError e,
    StackTrace? stackTrace,
  ) {
    return AppException(
      'Method not found: ${e.toString()}',
      code: ErrorCode.unknown.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // Unsupported Errors
  static AppException _handleUnsupportedError(
    UnsupportedError e,
    StackTrace? stackTrace,
  ) {
    return AppException(
      'Unsupported operation: ${e.message}',
      code: ErrorCode.platformNotSupported.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // Concurrent Modification Errors
  static AppException _handleConcurrentModificationError(
    ConcurrentModificationError e,
    StackTrace? stackTrace,
  ) {
    return AppException(
      'Concurrent modification error',
      code: ErrorCode.unknown.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // Out of Memory Errors
  static AppException _handleOutOfMemoryError(
    OutOfMemoryError e,
    StackTrace? stackTrace,
  ) {
    return AppException(
      'Out of memory error',
      code: ErrorCode.unknown.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }

  // Stack Overflow Errors
  static AppException _handleStackOverflowError(
    StackOverflowError e,
    StackTrace? stackTrace,
  ) {
    return AppException(
      'Stack overflow error',
      code: ErrorCode.unknown.code,
      originalError: e,
      stackTrace: stackTrace,
    );
  }
}
