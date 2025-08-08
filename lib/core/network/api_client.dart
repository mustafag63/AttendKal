import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  String? _baseUrl;

  Dio get dio => _dio;

  Future<void> initialize() async {
    // Discover available backend URL
    _baseUrl = await _discoverBackendUrl();

    _dio = Dio(BaseOptions(
      baseUrl: '$_baseUrl/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _addInterceptors();
  }

  Future<String> _discoverBackendUrl() async {
    for (final String url in AppConfig.possibleBaseUrls) {
      try {
        final testDio = Dio(BaseOptions(
          connectTimeout: const Duration(milliseconds: 1000),
          receiveTimeout: const Duration(milliseconds: 1000),
        ));

        final response = await testDio.get('$url/health');
        if (response.statusCode == 200) {
          debugPrint('🌐 Backend found at: $url');
          return url;
        }
      } catch (e) {
        debugPrint('❌ Backend not available at: $url');
        continue;
      }
    }

    // Fallback to default
    debugPrint('⚠️  Using fallback URL: ${AppConfig.possibleBaseUrls.first}');
    return AppConfig.possibleBaseUrls.first;
  }

  void _addInterceptors() {
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('🌐 API Request: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
              '✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
              '❌ API Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
          debugPrint('❌ Error message: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // Auth methods
  Future<Response> login(String email, String password) async {
    return await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register(String name, String email, String password) async {
    return await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': password,
    });
  }

  Future<Response> getCurrentUser() async {
    return await _dio.get('/auth/me');
  }

  Future<Response> logout() async {
    return await _dio.post('/auth/logout');
  }

  // Course methods
  Future<Response> getCourses() async {
    return await _dio.get('/courses');
  }

  Future<Response> createCourse(Map<String, dynamic> courseData) async {
    return await _dio.post('/courses', data: courseData);
  }

  Future<Response> updateCourse(
      String courseId, Map<String, dynamic> courseData) async {
    return await _dio.put('/courses/$courseId', data: courseData);
  }

  Future<Response> deleteCourse(String courseId) async {
    return await _dio.delete('/courses/$courseId');
  }

  // Attendance methods
  Future<Response> markAttendance(Map<String, dynamic> attendanceData) async {
    return await _dio.post('/attendance', data: attendanceData);
  }

  Future<Response> getAttendance({String? courseId, DateTime? date}) async {
    final queryParams = <String, dynamic>{};
    if (courseId != null) queryParams['courseId'] = courseId;
    if (date != null) queryParams['date'] = date.toIso8601String();

    return await _dio.get('/attendance', queryParameters: queryParams);
  }

  // Subscription methods (aligned with backend)
  Future<Response> getSubscription() async {
    return await _dio.get('/subscriptions');
  }

  Future<Response> upgradeSubscription(String planType) async {
    return await _dio.post('/subscriptions/upgrade', data: {
      'planType': planType,
    });
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get current base URL
  String? get baseUrl => _baseUrl;
}

// API Response models
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : json['data'],
      error: json['error'],
    );
  }
}

// API Exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() =>
      'ApiException: $message (Status: $statusCode, Code: $errorCode)';
}
