/// Error thrown by [ApiClient] for any non-successful response.
///
/// Carries the HTTP status, the backend business `code` (e.g. `E404`),
/// a human-readable `message` and the optional `errors[]` validation list.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.errors = const [],
  });

  final String message;
  final int? statusCode;
  final String? code;
  final List<String> errors;

  factory ApiException.network() => ApiException(
        message: 'Cannot reach the server. Check your connection '
            'and make sure the API is running.',
      );

  factory ApiException.sessionExpired() => ApiException(
        message: 'Your session has expired. Please sign in again.',
        statusCode: 401,
        code: 'E401',
      );

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;

  /// Single string suitable for a snackbar: message + validation details.
  String get displayMessage =>
      errors.isEmpty ? message : '$message\n• ${errors.join('\n• ')}';

  @override
  String toString() => 'ApiException($statusCode $code): $message';
}
