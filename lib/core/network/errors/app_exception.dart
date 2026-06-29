class AppException implements Exception {
  final String message;
  final int code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    required this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => '[$code] $message';
}

class ThrowException implements Exception {
  final ErrorCode errorCode;
  final Map<String, dynamic>? attributes;

  ThrowException(this.errorCode, {this.attributes});

  @override
  String toString() {
    if (attributes != null) {
      return _replaceAttributes(errorCode.message, attributes!);
    }
    return errorCode.message;
  }

  String _replaceAttributes(String message, Map<String, dynamic> attributes) {
    var result = message;
    attributes.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
}

enum ErrorCode {
  // ============================================================================
  userExists(1001, 'User already exists'),
  usernameInvalid(1002, 'Username must be at least {min} characters'),
  userNotFound(1003, 'User not found'),
  invalidCredentials(1004, 'Invalid credentials'),
  invalidPassword(1005, 'Invalid password'),
  unauthenticated(1006, 'Unauthenticated'),
  unauthorized(1007, 'You do not have permission'),
  tokenNotFound(1008, 'Token not found'),
  roleNotFound(1009, 'Role not found'),
  sessionExpired(1010, 'Session expired'),
  emailNotVerified(1011, 'Email not verified'),
  accountLocked(1012, 'Account locked'),
  accountSuspended(1013, 'Account suspended'),
  signInFailed(1014, 'Login failed'),
  userNotSignedIn(1015, 'User is not logged in'),

  // Generic Business
  duplicateEntry(3900, 'Duplicate entry'),
  resourceNotFound(3901, 'Resource not found'),

  // Media & Storage (4000-4999)
  mediaUploadFailed(4001, 'Media upload failed'),
  mediaDownloadFailed(4002, 'Media download failed'),
  storageQuotaExceeded(4003, 'Storage quota exceeded'),
  fileNotFound(4004, 'File not found'),
  fileSizeExceeded(4005, 'File size exceeded limit'),
  unsupportedFileType(4006, 'Unsupported file type'),
  imageProcessingFailed(4007, 'Image processing failed'),

  // Validation (5000-5999)
  validationFailed(5001, 'Validation failed: {field}'),
  requiredFieldMissing(5002, 'Required field: {field}'),
  invalidFormat(5003, 'Invalid format: {field}'),
  valueTooLong(5004, 'Value too long: {field}'),
  valueTooShort(5005, 'Value too short: {field}'),
  invalidDateRange(5006, 'Invalid date range'),
  invalidEnumValue(5007, 'Invalid value for: {field}'),

  // Rate Limiting (6000-6999)
  rateLimited(6001, 'Too many requests'),
  dailyLimitExceeded(6002, 'Daily limit exceeded'),

  // Network & Connectivity (7000-7999)
  networkError(7001, 'Network error'),
  connectionTimeout(7002, 'Connection timeout'),
  noInternetConnection(7003, 'No internet connection'),
  serverError(7004, 'Server error'),
  serviceUnavailable(7005, 'Service unavailable'),
  badGateway(7006, 'Bad gateway'),

  // Device & Platform (8000-8999)
  permissionDenied(8001, 'Permission denied'),
  deviceNotSupported(8002, 'Device not supported'),
  platformNotSupported(8003, 'Platform not supported'),
  cameraNotAvailable(8004, 'Camera not available'),
  locationNotAvailable(8005, 'Location not available'),
  notificationPermissionDenied(8006, 'Notification permission denied'),

  // Database & Cache (9000-9899)
  databaseError(9001, 'Database error'),
  cacheError(9002, 'Cache error'),
  dataCorrupted(9003, 'Data corrupted'),

  unknown(9999, 'Unknown error occurred');

  final int code;
  final String message;

  const ErrorCode(this.code, this.message);
}
