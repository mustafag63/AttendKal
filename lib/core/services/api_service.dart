import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

// Custom exceptions for API errors
class ApiError implements Exception {
  final String code;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? validationErrors;

  ApiError({
    required this.code,
    this.message,
    this.statusCode,
    this.validationErrors,
  });

  @override
  String toString() => 'ApiError($code): $message (Status: $statusCode)';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late ApiClient _apiClient;
  String? _authToken;
  String? _refreshToken;

  // Initialize the service
  Future<void> initialize() async {
    _apiClient = ApiClient();
    await _apiClient.initialize();

    // Load saved tokens
    await _loadTokens();

    // Setup auth interceptor
    _setupAuthInterceptor();
  }

  // Load saved tokens from storage
  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // Save tokens to storage
  Future<void> _saveTokens(String? authToken, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();

    if (authToken != null) {
      await prefs.setString('auth_token', authToken);
      _authToken = authToken;
    }

    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
      _refreshToken = refreshToken;
    }
  }

  // Clear tokens
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    _authToken = null;
    _refreshToken = null;
  }

  // Setup authentication interceptor
  void _setupAuthInterceptor() {
    _apiClient.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && _refreshToken != null) {
            // Try to refresh token
            try {
              await _refreshAuthToken();
              // Retry the original request
              final clonedRequest = await _apiClient.dio.request(
                error.requestOptions.path,
                options: Options(
                  method: error.requestOptions.method,
                  headers: {
                    ...error.requestOptions.headers,
                    'Authorization': 'Bearer $_authToken',
                  },
                ),
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              handler.resolve(clonedRequest);
              return;
            } catch (e) {
              await _clearTokens();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  // Refresh authentication token
  Future<void> _refreshAuthToken() async {
    try {
      final response = await _apiClient.dio.post('/auth/refresh-token', data: {
        'refreshToken': _refreshToken,
      });

      final raw = response.data;
      final isSuccess =
          (raw['status'] == 'success') || (raw['success'] == true);
      if (!isSuccess) {
        throw ApiError(code: 'refresh_failed', message: raw['message']);
      }
      final payload = raw['data'] ?? raw;
      await _saveTokens(payload['token'], payload['refreshToken']);
    } catch (e) {
      await _clearTokens();
      throw ApiError(
          code: 'refresh_failed', message: 'Failed to refresh token');
    }
  }

  // Handle API response (robust to multiple shapes)
  T _handleResponse<T>(Response response, T Function(dynamic) parser) {
    final status = response.statusCode ?? 0;
    if (status == 200 || status == 201) {
      final body = response.data;
      final isSuccess =
          (body['status'] == 'success') || (body['success'] == true);
      if (isSuccess) {
        final payload = body.containsKey('data') ? body['data'] : body;
        return parser(payload);
      }

      // Handle validation errors
      if (body['validationErrors'] != null) {
        throw ApiError(
          code: 'validation_error',
          message: body['message'] ?? 'Validation failed',
          statusCode: response.statusCode,
          validationErrors: Map<String, dynamic>.from(body['validationErrors']),
        );
      }

      throw ApiError(
        code: body['code'] ?? 'unknown',
        message: body['message'] ?? 'Unknown error',
        statusCode: response.statusCode,
      );
    } else {
      throw ApiError(
        code: 'http_error',
        message: 'HTTP Error ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  // --- Authentication Methods ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.login(email, password);
      final data =
          _handleResponse(response, (data) => Map<String, dynamic>.from(data));

      // Save tokens
      await _saveTokens(data['token'], data['refreshToken']);

      return data;
    } on DioException catch (e) {
      final data = e.response?.data;
      throw ApiError(
        code: (data is Map && data['code'] != null)
            ? data['code']
            : 'network_error',
        message: (data is Map && data['message'] != null)
            ? data['message']
            : e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await _apiClient.register(name, email, password);
      final data =
          _handleResponse(response, (data) => Map<String, dynamic>.from(data));

      // Save tokens
      await _saveTokens(data['token'], data['refreshToken']);

      return data;
    } on DioException catch (e) {
      final data = e.response?.data;
      throw ApiError(
        code: (data is Map && data['code'] != null)
            ? data['code']
            : 'network_error',
        message: (data is Map && data['message'] != null)
            ? data['message']
            : e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _clearTokens();
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiClient.getCurrentUser();
      return _handleResponse(response, (data) {
        if (data is Map && data.containsKey('user'))
          return Map<String, dynamic>.from(data['user']);
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{};
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      throw ApiError(
        code: (data is Map && data['code'] != null)
            ? data['code']
            : 'network_error',
        message: (data is Map && data['message'] != null)
            ? data['message']
            : e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  // --- Course Methods ---

  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _apiClient.getCourses();
      return _handleResponse(response, (data) {
        if (data is Map && data['courses'] is List) {
          return List<Map<String, dynamic>>.from(data['courses']);
        }
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return <Map<String, dynamic>>[];
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      throw ApiError(
        code: (data is Map && data['code'] != null)
            ? data['code']
            : 'network_error',
        message: (data is Map && data['message'] != null)
            ? data['message']
            : e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> createCourse(
      Map<String, dynamic> courseData) async {
    try {
      final response = await _apiClient.createCourse(courseData);
      return _handleResponse(response, (data) {
        if (data is Map && data['course'] is Map) {
          return Map<String, dynamic>.from(data['course']);
        }
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{};
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      throw ApiError(
        code: (data is Map && data['code'] != null)
            ? data['code']
            : 'network_error',
        message: (data is Map && data['message'] != null)
            ? data['message']
            : e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> updateCourse(
      String courseId, Map<String, dynamic> courseData) async {
    try {
      final response = await _apiClient.updateCourse(courseId, courseData);
      return _handleResponse(response, (data) {
        if (data is Map && data['course'] is Map) {
          return Map<String, dynamic>.from(data['course']);
        }
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{};
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      throw ApiError(
        code: (data is Map && data['code'] != null)
            ? data['code']
            : 'network_error',
        message: (data is Map && data['message'] != null)
            ? data['message']
            : e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _apiClient.deleteCourse(courseId);
    } on DioException catch (e) {
      final data = e.response?.data;
      throw ApiError(
        code: (data is Map && data['code'] != null)
            ? data['code']
            : 'network_error',
        message: (data is Map && data['message'] != null)
            ? data['message']
            : e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  // --- Attendance Methods ---

  Future<Map<String, dynamic>> markAttendance(
      Map<String, dynamic> attendanceData) async {
    try {
      final response = await _apiClient.markAttendance(attendanceData);
      return _handleResponse(response, (data) {
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{};
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      throw ApiError(
        code: (data is Map && data['code'] != null)
            ? data['code']
            : 'network_error',
        message: (data is Map && data['message'] != null)
            ? data['message']
            : e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAttendance(
      {String? courseId, DateTime? date}) async {
    try {
      final response =
          await _apiClient.getAttendance(courseId: courseId, date: date);
      return _handleResponse(response, (data) {
        if (data is Map && data['attendances'] is List) {
          return List<Map<String, dynamic>>.from(data['attendances']);
        }
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return <Map<String, dynamic>>[];
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      throw ApiError(
        code: (data is Map && data['code'] != null)
            ? data['code']
            : 'network_error',
        message: (data is Map && data['message'] != null)
            ? data['message']
            : e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  // --- Subscription Methods ---

  Future<Map<String, dynamic>> getSubscription() async {
    try {
      final response = await _apiClient.getSubscription();
      return _handleResponse(response, (data) {
        if (data is Map && data['subscription'] is Map) {
          return Map<String, dynamic>.from(data['subscription']);
        }
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{};
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      throw ApiError(
        code: (data is Map && data['code'] != null)
            ? data['code']
            : 'network_error',
        message: (data is Map && data['message'] != null)
            ? data['message']
            : e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> upgradeSubscription(String planType) async {
    try {
      final response = await _apiClient.upgradeSubscription(planType);
      return _handleResponse(response, (data) {
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{};
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      throw ApiError(
        code: (data is Map && data['code'] != null)
            ? data['code']
            : 'network_error',
        message: (data is Map && data['message'] != null)
            ? data['message']
            : e.message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  // --- Health Check ---

  Future<bool> checkHealth() async {
    return await _apiClient.checkHealth();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _authToken != null;

  // Get auth token
  String? get authToken => _authToken;
}
