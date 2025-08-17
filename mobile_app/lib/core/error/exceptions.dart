import 'package:dio/dio.dart';

// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  const AppException(this.message, {this.code, this.data});

  @override
  String toString() => 'AppException: $message';
}

// Specific exception types
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException(
    super.message, {
    super.code,
    super.data,
    this.errors,
  });
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.code, super.data});
}

class AuthorizationException extends AppException {
  const AuthorizationException(super.message, {super.code, super.data});
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.data});
}

class ConflictException extends AppException {
  const ConflictException(super.message, {super.code, super.data});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.data});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.data});
}

class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code, super.data});
}

// Exception mapper
class ExceptionMapper {
  static AppException fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Request timeout occurred',
          code: 'TIMEOUT',
          data: dioException.response?.data,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection',
          code: 'NO_CONNECTION',
          data: dioException.response?.data,
        );

      case DioExceptionType.badResponse:
        return _mapResponseException(dioException);

      case DioExceptionType.cancel:
        return NetworkException(
          'Request was cancelled',
          code: 'CANCELLED',
          data: dioException.response?.data,
        );

      case DioExceptionType.unknown:
      default:
        return NetworkException(
          'Unknown network error occurred',
          code: 'UNKNOWN',
          data: dioException.response?.data,
        );
    }
  }

  static AppException _mapResponseException(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final data = dioException.response?.data;
    final message = _extractMessage(data) ?? 'An error occurred';

    switch (statusCode) {
      case 400:
        return ValidationException(
          message,
          code: 'VALIDATION_ERROR',
          data: data,
          errors: _extractValidationErrors(data),
        );

      case 401:
        return AuthenticationException(
          message,
          code: 'UNAUTHORIZED',
          data: data,
        );

      case 403:
        return AuthorizationException(message, code: 'FORBIDDEN', data: data);

      case 404:
        return NotFoundException(message, code: 'NOT_FOUND', data: data);

      case 409:
        return ConflictException(message, code: 'CONFLICT', data: data);

      case 422:
        return ValidationException(
          message,
          code: 'UNPROCESSABLE_ENTITY',
          data: data,
          errors: _extractValidationErrors(data),
        );

      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
      case 505:
        return ServerException(message, code: 'SERVER_ERROR', data: data);

      default:
        return NetworkException(message, code: 'HTTP_$statusCode', data: data);
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? data['detail'] ?? data['msg'];
    }

    if (data is String) {
      return data;
    }

    return null;
  }

  static Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data == null || data is! Map<String, dynamic>) return null;

    // Handle Laravel-style validation errors
    if (data.containsKey('errors') && data['errors'] is Map) {
      final errors = data['errors'] as Map<String, dynamic>;
      final result = <String, List<String>>{};

      for (final entry in errors.entries) {
        if (entry.value is List) {
          result[entry.key] = List<String>.from(entry.value);
        } else if (entry.value is String) {
          result[entry.key] = [entry.value];
        }
      }

      return result.isEmpty ? null : result;
    }

    // Handle other validation error formats
    final result = <String, List<String>>{};
    for (final entry in data.entries) {
      if (entry.key != 'message' && entry.key != 'error') {
        if (entry.value is List) {
          result[entry.key] = List<String>.from(entry.value);
        } else if (entry.value is String) {
          result[entry.key] = [entry.value];
        }
      }
    }

    return result.isEmpty ? null : result;
  }
}
