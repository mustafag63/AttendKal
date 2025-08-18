import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'services/notification_service.dart';
import 'services/firebase_messaging_service.dart';
import 'firebase_options.dart';

// Global instances
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const _androidChannelId = 'attendkal_default';
const _androidChannelName = 'General';
const _androidChannelDesc = 'General notifications';

// Workmanager callback (background)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'scheduleNotifications':
        try {
          await NotificationService().scheduleUpcomingNotifications();
          return Future.value(true);
        } catch (e) {
          // Log hatası ama task'ı başarılı say
          return Future.value(true);
        }
      default:
        return Future.value(true);
    }
  });
}

// Bildirime app kapalıyken tıklama/aksiyon (background)
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  // Handle notification response in background
  NotificationService().handleNotificationResponse(response);
}

// Notification response handler
void _handleNotificationResponse(NotificationResponse response) {
  NotificationService().handleNotificationResponse(response);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Timezone
  tz.initializeTimeZones();
  // Hızlı test için Türkiye'ye sabitle (sonra flutter_timezone ile dinamik yaparsın)
  try {
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  } catch (_) {
    /* UTC fallback */
  }

  await _initializeNotifications();
  await _requestPermissions(); // iOS + Android 13+

  // NotificationService'i başlat
  await NotificationService().initialize();

  // Initialize Firebase Messaging
  await FirebaseMessagingService().initialize();

  // Background work'ü başlat
  await Workmanager().initialize(callbackDispatcher);

  // Periyodik bildirim kontrolü - günde 2 kez
  await Workmanager().registerPeriodicTask(
    'scheduleNotifications',
    'scheduleNotifications',
    frequency: const Duration(hours: 12),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: false,
      requiresCharging: false,
    ),
  );

  // Android özel ayarlar
  if (Platform.isAndroid) {
    await _setupAndroidChannel();
  }

  runApp(const ProviderScope(child: AttendkalApp()));
}

Future<void> _initializeNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS notification categories for action buttons
  final iosAttendanceCategory = DarwinNotificationCategory(
    'ATTENDANCE_CATEGORY',
    actions: <DarwinNotificationAction>[
      DarwinNotificationAction.plain('attended', 'Katıldım'),
      DarwinNotificationAction.plain('missed', 'Kaçırdım'),
      DarwinNotificationAction.plain('snooze10', '10dk Snooze'),
    ],
  );

  final iosSnoozeCategory = DarwinNotificationCategory(
    'SNOOZE_CATEGORY',
    actions: <DarwinNotificationAction>[
      DarwinNotificationAction.plain('attended', 'Katıldım'),
      DarwinNotificationAction.plain('missed', 'Kaçırdım'),
      DarwinNotificationAction.plain('snooze30', '30dk Snooze'),
      DarwinNotificationAction.plain('snooze2h', '2 Saat Snooze'),
    ],
  );

  final ios = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    notificationCategories: [iosAttendanceCategory, iosSnoozeCategory],
  );

  final settings = InitializationSettings(android: android, iOS: ios);

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (response) {
      // App açıkken bildirim/aksiyon tıklandı
      _handleNotificationResponse(response);
    },
    onDidReceiveBackgroundNotificationResponse:
        onDidReceiveBackgroundNotificationResponse,
  );
}

Future<void> _requestPermissions() async {
  // iOS izinleri
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  // Android 13+ (POST_NOTIFICATIONS)
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();
}

Future<void> _setupAndroidChannel() async {
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  const channel = AndroidNotificationChannel(
    _androidChannelId,
    _androidChannelName,
    description: _androidChannelDesc,
    importance: Importance.defaultImportance,
  );

  await androidPlugin?.createNotificationChannel(channel);
}
