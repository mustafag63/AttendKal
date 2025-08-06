class AppConfig {
  static const String appName = 'AttendKal';
  static const String appVersion = '1.0.0';

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
}
