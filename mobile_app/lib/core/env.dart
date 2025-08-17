class AppConfig {
  static const String appName = 'Attendkal';
  static const String version = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api';
  static const Duration requestTimeout = Duration(seconds: 30);

  // Database Configuration
  static const String databaseName = 'attendkal.db';
  static const int databaseVersion = 1;

  // Notification Configuration
  static const String notificationChannelId = 'attendkal_notifications';
  static const String notificationChannelName = 'Attendkal Notifications';
  static const String notificationChannelDescription =
      'Attendance reminders and updates';

  // Background Task Configuration
  static const String backgroundTaskName = 'attendkal_background_sync';
  static const Duration backgroundSyncInterval = Duration(hours: 1);

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
}

class Env {
  static const String apiBaseUrl = AppConfig.baseUrl;
  static const Duration requestTimeout = AppConfig.requestTimeout;
}
