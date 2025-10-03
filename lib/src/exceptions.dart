/// Base exception class for AdvanceListView errors
class AdvanceListViewException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AdvanceListViewException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AdvanceListViewException: $message';
}

/// Exception thrown when API returns an error status code
class ApiException extends AdvanceListViewException {
  final int statusCode;
  final dynamic responseBody;

  ApiException(
    this.statusCode,
    this.responseBody, {
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message ?? 'API Error ($statusCode)',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() =>
      'ApiException($statusCode): $message\nResponse: $responseBody';
}

/// Exception thrown when response format is invalid
class InvalidResponseFormatException extends AdvanceListViewException {
  final String expectedFormat;
  final String actualFormat;

  InvalidResponseFormatException(
    this.expectedFormat,
    this.actualFormat, {
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message ?? 'Invalid response format',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() =>
      'InvalidResponseFormatException: $message\nExpected: $expectedFormat, Got: $actualFormat';
}

/// Exception thrown when network request fails
class NetworkException extends AdvanceListViewException {
  NetworkException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when JSON parsing fails
class JsonParsingException extends AdvanceListViewException {
  JsonParsingException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'JsonParsingException: $message';
}
