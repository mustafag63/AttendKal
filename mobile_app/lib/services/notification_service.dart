import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:drift/drift.dart';
import '../data/local/db.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AppDatabase _db = AppDatabase.instance;

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
          defaultPresentAlert: true,
          defaultPresentSound: true,
          defaultPresentBadge: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request permissions for iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    if (response.payload != null) {
      final payload = json.decode(response.payload!);
      final reminderId = payload['reminderId'] as String;
      final actionType = payload['actionType'] as String?;

      if (actionType != null) {
        await _handleNotificationAction(reminderId, actionType, payload);
      }
    }
  }

  Future<void> _handleNotificationAction(
    String reminderId,
    String actionType,
    Map<String, dynamic> payload,
  ) async {
    NotificationActionType action;
    switch (actionType) {
      case 'attended':
        action = NotificationActionType.attended;
        break;
      case 'missed':
        action = NotificationActionType.missed;
        break;
      case 'snooze10':
        action = NotificationActionType.snooze10;
        break;
      case 'snooze30':
        action = NotificationActionType.snooze30;
        break;
      case 'snooze2h':
        action = NotificationActionType.snooze2h;
        break;
      default:
        return;
    }

    // Record the action
    await _db.insertNotificationAction(
      NotificationActionsCompanion(
        id: Value(_generateId()),
        reminderId: Value(reminderId),
        actionType: Value(action),
        timestamp: Value(DateTime.now().millisecondsSinceEpoch),
        sessionId: payload['sessionId'] != null
            ? Value(payload['sessionId'])
            : const Value.absent(),
        metadata: payload['metadata'] != null
            ? Value(payload['metadata'])
            : const Value.absent(),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    // Handle snooze actions
    if (action == NotificationActionType.snooze10 ||
        action == NotificationActionType.snooze30 ||
        action == NotificationActionType.snooze2h) {
      await _scheduleSnoozeNotification(reminderId, action, payload);
    }

    // Handle attendance actions - would be connected to attendance system
    if (action == NotificationActionType.attended ||
        action == NotificationActionType.missed) {
      // TODO: Connect to attendance system
      debugPrint(
        'Attendance action: $action for session: ${payload['sessionId']}',
      );
    }
  }

  Future<void> _scheduleSnoozeNotification(
    String reminderId,
    NotificationActionType snoozeType,
    Map<String, dynamic> originalPayload,
  ) async {
    Duration snoozeDuration;
    switch (snoozeType) {
      case NotificationActionType.snooze10:
        snoozeDuration = const Duration(minutes: 10);
        break;
      case NotificationActionType.snooze30:
        snoozeDuration = const Duration(minutes: 30);
        break;
      case NotificationActionType.snooze2h:
        snoozeDuration = const Duration(hours: 2);
        break;
      default:
        return;
    }

    final snoozeTime = DateTime.now().add(snoozeDuration);
    final notificationId = _generateNotificationId(
      reminderId,
      snoozeTime.millisecondsSinceEpoch,
    );

    await _scheduleNotification(
      id: notificationId,
      title: originalPayload['title'] ?? 'Ders Hatırlatıcısı',
      body: '${originalPayload['body'] ?? 'Dersiniz yaklaşıyor'} (Ertelendi)',
      scheduledTime: snoozeTime,
      payload: json.encode({
        ...originalPayload,
        'isSnooze': true,
        'snoozeCount': (originalPayload['snoozeCount'] ?? 0) + 1,
      }),
    );
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    final scheduledTime = DateTime.fromMillisecondsSinceEpoch(
      reminder.scheduledTime,
    );
    final notificationId = _generateNotificationId(
      reminder.id,
      reminder.scheduledTime,
    );

    // Update reminder with notification ID
    await _db.updateReminder(
      RemindersCompanion(
        id: Value(reminder.id),
        notificationId: Value(notificationId),
      ),
    );

    String title = reminder.title;
    String body = reminder.description ?? '';

    // Customize based on reminder type
    switch (reminder.type) {
      case ReminderType.courseMorning:
        title = '🌅 Bugün ders var!';
        body = reminder.description ?? 'Bugün dersleriniz var. Hazır olun!';
        break;
      case ReminderType.coursePreStart:
        title = '📚 Ders yaklaşıyor';
        body = reminder.description ?? 'Dersiniz 30 dakika içinde başlayacak.';
        break;
      case ReminderType.custom:
        // Keep original title and body
        break;
    }

    await _scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      payload: json.encode({
        'reminderId': reminder.id,
        'type': reminder.type.name,
        'courseId': reminder.courseId,
        'title': title,
        'body': body,
      }),
      actions: reminder.type != ReminderType.custom
          ? [
              const AndroidNotificationAction('attended', 'Katıldım'),
              const AndroidNotificationAction('missed', 'Kaçırdım'),
              const AndroidNotificationAction('snooze10', '10dk Snooze'),
            ]
          : null,
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    List<AndroidNotificationAction>? actions,
  }) async {
    final scheduledTz = tz.TZDateTime.from(scheduledTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'attendkal_reminders',
      'Ders Hatırlatıcıları',
      channelDescription: 'Ders ve toplantı hatırlatıcıları',
      importance: Importance.high,
      priority: Priority.high,
      actions: actions,
      autoCancel: false,
      ongoing: false,
      styleInformation: const BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTz,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Generate deterministic notification ID based on reminder ID and timestamp
  int _generateNotificationId(String reminderId, int timestamp) {
    final combined = '$reminderId$timestamp';
    return combined.hashCode.abs() % 2147483647; // Max int32 value
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    return '${timestamp}_$random';
  }

  /// Schedule notifications for the next 7-14 days
  Future<void> scheduleUpcomingNotifications() async {
    final now = DateTime.now();
    final startTime = now.millisecondsSinceEpoch;
    final endTime = now.add(const Duration(days: 14)).millisecondsSinceEpoch;

    // Get active reminders in the time range
    final reminders = await _db.getRemindersByTimeRange(startTime, endTime);

    // Cancel existing scheduled notifications
    await cancelAllNotifications();

    // Group notifications by minute to avoid duplicates
    final Map<String, List<Reminder>> groupedByMinute = {};

    for (final reminder in reminders) {
      final scheduledTime = DateTime.fromMillisecondsSinceEpoch(
        reminder.scheduledTime,
      );
      final minuteKey =
          '${scheduledTime.year}-${scheduledTime.month}-${scheduledTime.day}-${scheduledTime.hour}-${scheduledTime.minute}';

      groupedByMinute[minuteKey] ??= [];
      groupedByMinute[minuteKey]!.add(reminder);
    }

    // Schedule deduplicated notifications
    for (final entry in groupedByMinute.entries) {
      final reminders = entry.value;
      if (reminders.length == 1) {
        // Single reminder - schedule normally
        await scheduleReminder(reminders.first);
      } else {
        // Multiple reminders - combine into one notification
        await _scheduleCombinedNotification(reminders);
      }
    }
  }

  Future<void> _scheduleCombinedNotification(List<Reminder> reminders) async {
    final firstReminder = reminders.first;
    final scheduledTime = DateTime.fromMillisecondsSinceEpoch(
      firstReminder.scheduledTime,
    );

    final notificationId = _generateNotificationId(
      'combined_${reminders.map((r) => r.id).join('_')}',
      firstReminder.scheduledTime,
    );

    final titles = reminders.map((r) => r.title).toSet().toList();
    final title = titles.length == 1
        ? titles.first
        : '${titles.length} Hatırlatıcı';

    final body = reminders.length > 1
        ? 'Birden fazla hatırlatıcınız var'
        : reminders.first.description ?? '';

    await _scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      payload: json.encode({
        'reminders': reminders.map((r) => r.id).toList(),
        'isCombined': true,
        'title': title,
        'body': body,
      }),
    );
  }

  /// Initialize background work for notification scheduling
  Future<void> initializeBackgroundWork() async {
    await Workmanager().initialize(
      _backgroundTaskDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Schedule daily notification planning task
    await Workmanager().registerPeriodicTask(
      'notification_scheduler',
      'scheduleNotifications',
      frequency: const Duration(hours: 12), // Run twice daily
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  static void _backgroundTaskDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      switch (task) {
        case 'scheduleNotifications':
          await NotificationService().scheduleUpcomingNotifications();
          return Future.value(true);
        default:
          return Future.value(false);
      }
    });
  }
}
