class AppConfig {
  static const String appName = 'AttendKal';
  static const String appVersion = '1.0.0';

  // Feature flags
  static const bool subscriptionEnabled = true; // Enabled after fixing Firebase
  static const bool analyticsEnabled = true;
  static const bool notificationsEnabled = true;

  // Subscription limits
  static const int freeCoursesLimit = 2;
  static const int proCoursesLimit = -1; // -1 means unlimited

  // Firebase collection names
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String attendanceCollection = 'attendance';
  static const String subscriptionsCollection = 'subscriptions';

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
    for (String url in possibleBaseUrls) {
      try {
        final uri = Uri.parse('$url/health');
        final response = await Future.any([
          _checkUrl(uri),
          Future.delayed(const Duration(milliseconds: 500), () => false),
        ]);
        if (response == true) {
          return url;
        }
      } catch (e) {
        continue;
      }
    }
    // Fallback to default
    return possibleBaseUrls.first;
  }

  static Future<bool> _checkUrl(Uri uri) async {
    try {
      // Bu method network paketini kullanacak, şimdilik basit bir implementasyon
      return true; // ApiClient'da implement edilecek
    } catch (e) {
      return false;
    }
  }

  // Maintenance messages
  static const String subscriptionMaintenanceMessage =
      'Abonelik bölümü şu anda bakımda. Kısa süre içinde tekrar deneyin.';
}
