import 'package:dio/dio.dart';

class AppConfig {
  static const String appName = 'AttendKal';
  static const String appVersion = '1.0.0';

  // Feature flags
  static const bool subscriptionEnabled = false;
  static const bool analyticsEnabled = true;
  static const bool notificationsEnabled = true;

  // Subscription limits
  static const int freeCoursesLimit = 2;
  static const int proCoursesLimit = -1; // -1 means unlimited

  // Notification settings
  static const String notificationChannelId = 'attendkal_notifications';
  static const String notificationChannelName = 'AttendKal Notifications';
  static const String notificationChannelDescription =
      'Notifications for course reminders and updates';

  // Shared preferences keys
  static const String userIdKey = 'user_id';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String subscriptionTypeKey = 'subscription_type';
  static const String darkModeKey = 'dark_mode';
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';

  // API configuration - Dynamic port support
  static const List<String> possibleBaseUrls = [
    'http://localhost:3000',
    'http://localhost:3001',
    'http://localhost:3002',
    'http://localhost:3003',
    'http://localhost:3004',
  ];
  static const String apiVersion = 'v1';

  // Get available backend URL
  static Future<String> getBackendUrl() async {
    for (final String url in possibleBaseUrls) {
      try {
        final dio = Dio(BaseOptions(
          connectTimeout: const Duration(milliseconds: 1500),
          receiveTimeout: const Duration(milliseconds: 1500),
        ));

        final response = await dio.get('$url/health');
        if (response.statusCode == 200) {
          return url;
        }
      } catch (e) {
        continue;
      }
    }
    // Fallback to default
    return possibleBaseUrls.first;
  }

  // Request timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // API Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Error messages
  static const String networkErrorMessage =
      'Network connection error. Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String authErrorMessage =
      'Authentication failed. Please login again.';
  static const String subscriptionMaintenanceMessage =
      'Subscription service is currently under maintenance. Please try again later.';
}
