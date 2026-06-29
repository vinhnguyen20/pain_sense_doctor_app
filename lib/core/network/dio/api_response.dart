import 'package:app_doctor/core/network/dio/paginated_response.dart';
import 'package:app_doctor/core/network/errors/error_logger.dart';
import 'package:app_doctor/core/network/errors/exception_handler.dart';

class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;
  final StackTrace? stackTrace;

  const ApiResponse({
    required this.code,
    required this.message,
    this.data,
    this.stackTrace,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(code: 0, message: 'Success', data: data);
  }

  factory ApiResponse.failure(dynamic error, [StackTrace? stackTrace]) {
    final exception = ExceptionHandler.handle(error, stackTrace);
    ErrorLogger.log(exception);

    return ApiResponse(
      code: exception.code,
      message: exception.message,
      stackTrace: exception.stackTrace,
    );
  }

  /// Standard response: `{ "message": "...", "data": { ... } }`
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      code: 0,
      message: json['message'] as String? ?? 'Success',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  /// Paginated response: `{ "message": "...", "data": { "items": [...], "next_cursor": "...", "limit": 10 } }`
  static ApiResponse<PaginatedResponse<T>> fromPaginatedJson<T>(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    final raw = json['data'] as Map<String, dynamic>?;

    final paginated = raw != null
        ? PaginatedResponse<T>.fromJson(raw, fromJsonT)
        : null;

    return ApiResponse<PaginatedResponse<T>>(
      code: 0,
      message: json['message'] as String? ?? 'Success',
      data: paginated,
    );
  }

  bool get isSuccess => code == 0;
  bool get isFailure => !isSuccess;
}
