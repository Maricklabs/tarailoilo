/// Error type that services throw so screens can show a friendly message
/// in their [ErrorView] instead of a raw stack trace.
class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// Message that is safe to show to the user.
  final String message;

  /// The original error, kept for debugging/logging.
  final Object? cause;

  @override
  String toString() => message;
}

/// Thrown when an online-only feature is used without internet.
class OfflineException extends AppException {
  const OfflineException([super.message = 'This feature needs internet.']);
}
