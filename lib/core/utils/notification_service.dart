import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../config/app_config.dart';

/// Handles local and FCM notifications
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Initialize timezone data, local notifications, and FCM
  static Future<void> initialize() async {
    // Initialize timezone database and set local timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    // Local notification settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }

    // FCM setup
    await _initializeFirebaseMessaging();
  }

  static Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      description: AppConfig.notificationChannelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _initializeFirebaseMessaging() async {
    // Request iOS permissions
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Print FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background tap handler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundTap);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Navigate or handle action
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
    if (message.notification != null) {
      showNotification(
        title: message.notification!.title ?? AppConfig.appName,
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  static void _handleBackgroundTap(RemoteMessage message) {
    print('Background notification tapped: ${message.notification?.title}');
    // Navigate or handle action based on message.data
  }

  /// Show an immediate local notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch % 100000;
    const androidDetails = AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule a notification at a specific [scheduledDate]
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch % 100000;
    const androidDetails = AndroidNotificationDetails(
      AppConfig.notificationChannelId,
      AppConfig.notificationChannelName,
      channelDescription: AppConfig.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// Retrieve the current FCM token
  static Future<String?> getFCMToken() async {
    return _firebaseMessaging.getToken();
  }

  /// Stream for token refresh events
  static Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;
}
