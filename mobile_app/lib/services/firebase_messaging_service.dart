import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:drift/drift.dart';
import '../data/local/db.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AppDatabase _db = AppDatabase.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
      'Firebase Messaging permission granted: ${settings.authorizationStatus}',
    );

    // Get FCM token
    await _getFCMToken();

    // Configure message handlers
    await _configureMessageHandlers();

    // Initialize local notifications for Android
    if (Platform.isAndroid) {
      await _initializeLocalNotifications();
    }
  }

  /// Get FCM token
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      // Store token in local database
      if (_fcmToken != null) {
        await _storeFCMToken(_fcmToken!);
      }

      return _fcmToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Store FCM token in database
  Future<void> _storeFCMToken(String token) async {
    try {
      await _db.setSetting('fcm_token', token);
      await _db.setSetting(
        'fcm_token_updated_at',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      debugPrint('Error storing FCM token: $e');
    }
  }

  /// Get stored FCM token
  Future<String?> getStoredFCMToken() async {
    try {
      return await _db.getSetting('fcm_token');
    } catch (e) {
      debugPrint('Error getting stored FCM token: $e');
      return null;
    }
  }

  /// Configure message handlers
  Future<void> _configureMessageHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle notification tap when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token refreshed: $newToken');
      _fcmToken = newToken;
      await _storeFCMToken(newToken);
      // TODO: Send new token to backend
    });
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Show local notification for Android (iOS shows automatically)
    if (Platform.isAndroid) {
      _showLocalNotification(message);
    }

    // Store message in database
    _storeReceivedMessage(message);
  }

  /// Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
    debugPrint('Data: ${message.data}');

    // Handle navigation based on message data
    _handleNotificationNavigation(message.data);
  }

  /// Initialize local notifications for Android
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          final data = json.decode(response.payload!);
          _handleNotificationNavigation(data);
        }
      },
    );
  }

  /// Show local notification for Android
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'attendkal_push',
          'Push Notifications',
          channelDescription: 'Push notifications from Attendkal server',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Attendkal',
      message.notification?.body ?? '',
      details,
      payload: json.encode(message.data),
    );
  }

  /// Store received message in database
  Future<void> _storeReceivedMessage(RemoteMessage message) async {
    try {
      // Store in notification_actions table for tracking
      await _db.insertNotificationAction(
        NotificationActionsCompanion(
          id: Value(
            message.messageId ??
                DateTime.now().millisecondsSinceEpoch.toString(),
          ),
          reminderId: message.data['reminderId'] != null
              ? Value(message.data['reminderId'])
              : const Value.absent(),
          actionType: Value(
            NotificationActionType.missed,
          ), // Default to received
          timestamp: Value(DateTime.now().millisecondsSinceEpoch),
          sessionId: message.data['sessionId'] != null
              ? Value(message.data['sessionId'])
              : const Value.absent(),
          metadata: Value(
            json.encode({
              'title': message.notification?.title,
              'body': message.notification?.body,
              'data': message.data,
              'messageId': message.messageId,
              'sentTime': message.sentTime?.millisecondsSinceEpoch,
              'type': 'push_received',
            }),
          ),
          createdAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
    } catch (e) {
      debugPrint('Error storing received message: $e');
    }
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? targetId = data['targetId'];

    debugPrint(
      'Handling notification navigation - Type: $type, TargetId: $targetId',
    );

    switch (type) {
      case 'reminder':
        // Navigate to reminders screen
        // TODO: Implement navigation
        break;
      case 'attendance':
        // Navigate to attendance screen
        // TODO: Implement navigation
        break;
      case 'course':
        // Navigate to specific course
        // TODO: Implement navigation
        break;
      default:
        // Navigate to home screen
        break;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Subscribe to user-specific topics
  Future<void> subscribeToUserTopics(String userId) async {
    // Subscribe to general user notifications
    await subscribeToTopic('user_$userId');

    // Subscribe to general app notifications
    await subscribeToTopic('attendkal_general');
  }

  /// Unsubscribe from user-specific topics
  Future<void> unsubscribeFromUserTopics(String userId) async {
    await unsubscribeFromTopic('user_$userId');
  }

  /// Send FCM token to backend
  Future<bool> sendTokenToBackend(String userId, String? authToken) async {
    if (_fcmToken == null) {
      await _getFCMToken();
    }

    if (_fcmToken == null) return false;

    try {
      // TODO: Use AttendanceApiService to send token
      // For now, just simulate the API call
      debugPrint('Sending FCM token to backend for user: $userId');
      debugPrint('Token: $_fcmToken');

      // Store that token was sent
      await _db.setSetting(
        'fcm_token_sent_at',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );

      return true;
    } catch (e) {
      debugPrint('Error sending FCM token to backend: $e');
      return false;
    }
  }

  /// Check if FCM token needs to be refreshed/resent
  Future<bool> shouldRefreshToken() async {
    try {
      final lastSent = await _db.getSetting('fcm_token_sent_at');
      final lastUpdated = await _db.getSetting('fcm_token_updated_at');

      if (lastSent == null || lastUpdated == null) return true;

      final sentTime = int.parse(lastSent);
      final updatedTime = int.parse(lastUpdated);

      // Token was updated after it was sent to backend
      return updatedTime > sentTime;
    } catch (e) {
      debugPrint('Error checking token refresh status: $e');
      return true;
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase
  await Firebase.initializeApp();

  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');

  // Store message in database
  try {
    final db = AppDatabase.instance;
    await db.insertNotificationAction(
      NotificationActionsCompanion(
        id: Value(
          message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        ),
        reminderId: message.data['reminderId'] != null
            ? Value(message.data['reminderId'])
            : const Value.absent(),
        actionType: Value(NotificationActionType.missed), // Default to received
        timestamp: Value(DateTime.now().millisecondsSinceEpoch),
        sessionId: message.data['sessionId'] != null
            ? Value(message.data['sessionId'])
            : const Value.absent(),
        metadata: Value(
          json.encode({
            'title': message.notification?.title,
            'body': message.notification?.body,
            'data': message.data,
            'messageId': message.messageId,
            'sentTime': message.sentTime?.millisecondsSinceEpoch,
            'type': 'push_background',
          }),
        ),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  } catch (e) {
    debugPrint('Error storing background message: $e');
  }
}
