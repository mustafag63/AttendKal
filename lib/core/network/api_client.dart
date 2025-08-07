import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000/api';

  late Dio _dio;
  late SharedPreferences _prefs;

  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Request interceptor for adding auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final options = error.requestOptions;
            final token = _prefs.getString('access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            try {
              final response = await _dio.fetch(options);
              handler.resolve(response);
              return;
            } catch (e) {
              // If retry fails, proceed with original error
            }
          }
          // Clear tokens and redirect to login
          await _clearTokens();
        }
        handler.next(error);
      },
    ));
  }

  // Authentication methods
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      });

      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        await _saveTokens(data['token'], data['refreshToken']);
        return ApiResponse.success(data);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Registration failed');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        await _saveTokens(data['token'], data['refreshToken']);
        return ApiResponse.success(data);
      }

      return ApiResponse.error(response.data['message'] ?? 'Login failed');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      final refreshToken = _prefs.getString('refresh_token');
      await _dio.post('/auth/logout', data: {
        'refreshToken': refreshToken,
      });

      await _clearTokens();
      return ApiResponse.success(null);
    } on DioException catch (e) {
      await _clearTokens(); // Clear tokens even if request fails
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');

      if (response.data['status'] == 'success') {
        return ApiResponse.success(response.data['data']);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to get user');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // Course methods
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourses() async {
    try {
      final response = await _dio.get('/courses');

      if (response.data['status'] == 'success') {
        return ApiResponse.success(
            List<Map<String, dynamic>>.from(response.data['data']));
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to get courses');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createCourse({
    required String name,
    required String code,
    required String instructor,
    required String description,
    required String color,
    required List<Map<String, dynamic>> schedule,
  }) async {
    try {
      final response = await _dio.post('/courses', data: {
        'name': name,
        'code': code,
        'instructor': instructor,
        'description': description,
        'color': color,
        'schedule': schedule,
      });

      if (response.data['status'] == 'success') {
        return ApiResponse.success(response.data['data']);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to create course');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<void>> deleteCourse(String courseId) async {
    try {
      final response = await _dio.delete('/courses/$courseId');

      if (response.data['status'] == 'success') {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to delete course');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // Attendance methods
  Future<ApiResponse<List<Map<String, dynamic>>>> getAttendance({
    String? courseId,
  }) async {
    try {
      final url =
          courseId != null ? '/attendance/course/$courseId' : '/attendance';
      final response = await _dio.get(url);

      if (response.data['status'] == 'success') {
        return ApiResponse.success(
            List<Map<String, dynamic>>.from(response.data['data']));
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to get attendance');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> markAttendance({
    required String courseId,
    required String status,
    required DateTime date,
    String? note,
  }) async {
    try {
      final response = await _dio.post('/attendance', data: {
        'courseId': courseId,
        'status': status,
        'date': date.toIso8601String(),
        if (note != null) 'note': note,
      });

      if (response.data['status'] == 'success') {
        return ApiResponse.success(response.data['data']);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to mark attendance');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // Subscription methods
  Future<ApiResponse<Map<String, dynamic>>> getSubscription() async {
    try {
      final response = await _dio.get('/subscriptions');

      if (response.data['status'] == 'success') {
        return ApiResponse.success(response.data['data']);
      }

      return ApiResponse.error(
          response.data['message'] ?? 'Failed to get subscription');
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    }
  }

  // Private methods
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _prefs.setString('access_token', accessToken);
    await _prefs.setString('refresh_token', refreshToken);
  }

  Future<void> _clearTokens() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _prefs.getString('refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post('/auth/refresh-token', data: {
        'refreshToken': refreshToken,
      });

      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        await _saveTokens(data['token'], data['refreshToken']);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final message = error.response?.data?['message'];
        return message ?? 'Server error occurred.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return 'No internet connection.';
        }
        return 'An unexpected error occurred.';
      default:
        return 'An error occurred.';
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.success(this.data)
      : success = true,
        error = null;
  ApiResponse.error(this.error)
      : success = false,
        data = null;
}
