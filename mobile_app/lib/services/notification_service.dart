import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:drift/drift.dart';

import '../data/local/db.dart';

/// ----------------------
/// Workmanager dispatcher
/// ----------------------
/// Workmanager, iOS/Android background entrypoint'inin üst düzey (top-level)
/// bir fonksiyon olmasını tercih ediyor. Bu yüzden burada tanımlıyoruz.
void notificationBackgroundTaskDispatcher() {
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

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AppDatabase _db = AppDatabase.instance;

  bool _tzReady = false;

  /// ----------------------
  /// PUBLIC API
  /// ----------------------
  Future<void> initialize() async {
    // 1) Timezone init (idempotent)
    await _ensureTimezoneInitialized();

    // 2) Initialization Settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS action kategorileri (attended, missed, snoozes)
    final iosCategories = <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        'ATTENDKAL_CATEGORY',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('attended', 'Katıldım'),
          DarwinNotificationAction.plain('missed', 'Kaçırdım'),
          DarwinNotificationAction.plain('snooze10', '10dk Snooze'),
          DarwinNotificationAction.plain('snooze30', '30dk Snooze'),
          DarwinNotificationAction.plain('snooze2h', '2s Snooze'),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.customDismissAction,
        },
      ),
    ];

    final iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
      notificationCategories: iosCategories,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onNotificationResponse,
    );

    // 3) iOS izinleri
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    // 4) Android 8+ kanal
    await _ensureAndroidChannel();

    // 5) Workmanager init (günlük planlayıcı)
    await initializeBackgroundWork();
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    // Tek seferlik plan: scheduledTime kullanılıyor
    final scheduledTime = DateTime.fromMillisecondsSinceEpoch(
      reminder.scheduledTime,
    );

    final notificationId = _generateNotificationId(
      reminder.id,
      reminder.scheduledTime,
    );

    // DB'deki notificationId'yi güncelle
    final existingReminder = await _db.getReminderById(reminder.id);
    if (existingReminder != null) {
      final updatedReminder = Reminder(
        id: existingReminder.id,
        userId: existingReminder.userId,
        courseId: existingReminder.courseId,
        title: existingReminder.title,
        description: existingReminder.description,
        type: existingReminder.type,
        scheduledTime: existingReminder.scheduledTime,
        repeatType: existingReminder.repeatType,
        repeatInterval: existingReminder.repeatInterval,
        isActive: existingReminder.isActive,
        notificationId: notificationId,
        metadata: existingReminder.metadata,
        morningOfClass: existingReminder.morningOfClass,
        minutesBefore: existingReminder.minutesBefore,
        thresholdAlerts: existingReminder.thresholdAlerts,
        cron: existingReminder.cron,
        enabled: existingReminder.enabled,
        createdAt: existingReminder.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _db.updateReminder(updatedReminder);
    }

    String title = reminder.title;
    String body = reminder.description ?? '';

    // Tip bazlı metinleri zenginleştir
    switch (reminder.type) {
      case ReminderType.courseMorning:
        title = '🌅 Bugün ders var!';
        body = body.isNotEmpty ? body : 'Bugün dersleriniz var. Hazır olun!';
        break;
      case ReminderType.coursePreStart:
        title = '📚 Ders yaklaşıyor';
        body = body.isNotEmpty ? body : 'Dersiniz yakında başlayacak.';
        break;
      case ReminderType.custom:
        // özgün başlık & içerik
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
      // Ders tipi bildirimlerde action butonları
      androidActions: reminder.type != ReminderType.custom
          ? const [
              AndroidNotificationAction('attended', 'Katıldım'),
              AndroidNotificationAction('missed', 'Kaçırdım'),
              AndroidNotificationAction('snooze10', '10dk Snooze'),
            ]
          : null,
      // Tek seferlik olduğu için repeat yok
      repeatsDailyAtSameTime: false,
    );
  }

  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Önümüzdeki 14 gün için plan oluşturup zamanlar
  Future<void> scheduleUpcomingNotifications() async {
    await _ensureTimezoneInitialized();

    final now = DateTime.now();
    final endTime = now.add(const Duration(days: 14));

    // Aktif hatırlatıcılar
    final reminders = await _db.getRemindersByTimeRange(now, endTime);

    // Çakışmaları azaltmak için tüm eski planı temizle (istenirse soft-diff'e çevrilebilir)
    await cancelAllNotifications();

    // Aynı dakikadaki birden fazla hatırlatıcıyı birleştir
    final Map<String, List<Reminder>> groupedByMinute = {};
    for (final reminder in reminders) {
      final scheduledTime = DateTime.fromMillisecondsSinceEpoch(
        reminder.scheduledTime,
      );
      final minuteKey =
          '${scheduledTime.year}-${scheduledTime.month}-${scheduledTime.day}-${scheduledTime.hour}-${scheduledTime.minute}';
      groupedByMinute.putIfAbsent(minuteKey, () => <Reminder>[]).add(reminder);
    }

    for (final entry in groupedByMinute.entries) {
      final list = entry.value;
      if (list.length == 1) {
        await scheduleReminder(list.first);
      } else {
        await _scheduleCombinedNotification(list);
      }
    }
  }

  /// Arka planda çalışacak günlük/yarım günlük iş planlayıcısı
  Future<void> initializeBackgroundWork() async {
    await Workmanager().initialize(
      notificationBackgroundTaskDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Günde iki kez planı tazele
    await Workmanager().registerPeriodicTask(
      'notification_scheduler',
      'scheduleNotifications',
      frequency: const Duration(hours: 12),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
    );
  }

  /// ----------------------
  /// INTERNALS
  /// ----------------------
  Future<void> _ensureTimezoneInitialized() async {
    if (_tzReady) return;
    try {
      tzdata.initializeTimeZones();
      // Cihazın lokal TZ'sini kullan
      tz.setLocalLocation(tz.getLocation(_safeLocalTimezoneName()));
      _tzReady = true;
    } catch (_) {
      // Yine de tz.local çalışır; setLocalLocation atlanırsa bile zonedSchedule local saatle gider.
      _tzReady = true;
    }
  }

  String _safeLocalTimezoneName() {
    // Bazı ortamlarda DateTime.now().timeZoneName 'GMT+3' gibi dönebilir,
    // bu durumda 'Europe/Istanbul' güvenli bir default.
    final name = DateTime.now().timeZoneName;
    if (name.contains('/') && !name.contains('GMT')) return name;
    return 'Europe/Istanbul';
  }

  Future<void> _ensureAndroidChannel() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;

    const channel = AndroidNotificationChannel(
      'attendkal_reminders',
      'Ders Hatırlatıcıları',
      description: 'Ders ve toplantı hatırlatıcıları',
      importance: Importance.high,
    );

    await androidPlugin.createNotificationChannel(channel);
  }

  Future<void> _onNotificationResponse(NotificationResponse response) async {
    try {
      final payloadStr = response.payload;
      if (payloadStr == null) return;

      final payload = json.decode(payloadStr) as Map<String, dynamic>;
      final reminderId = payload['reminderId'] as String?;
      final actionType = response.actionId?.isNotEmpty == true
          ? response.actionId
          : (payload['actionType'] as String?);

      if (reminderId == null) return;
      if (actionType != null) {
        await _handleNotificationAction(reminderId, actionType, payload);
      }
    } catch (e) {
      debugPrint('onNotificationResponse parse error: $e');
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

    // Aksiyon kaydı
    await _db.insertNotificationAction(
      NotificationActionsCompanion.insert(
        id: _generateId(),
        reminderId: reminderId,
        actionType: action,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        sessionId: payload['sessionId'] != null
            ? Value(payload['sessionId'])
            : const Value.absent(),
        metadata: payload['metadata'] != null
            ? Value(payload['metadata'])
            : const Value.absent(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    // Snooze
    if (action == NotificationActionType.snooze10 ||
        action == NotificationActionType.snooze30 ||
        action == NotificationActionType.snooze2h) {
      await _scheduleSnoozeNotification(reminderId, action, payload);
    }

    // Katılım/Kaçırma (ileride yoklama sistemiyle bağlanacak)
    if (action == NotificationActionType.attended ||
        action == NotificationActionType.missed) {
      debugPrint(
        'Attendance action: $action for session: ${payload['sessionId']}',
      );
      // TODO: Backend ack / yoklama entegrasyonu
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
      title: (originalPayload['title'] as String?) ?? 'Ders Hatırlatıcısı',
      body:
          '${(originalPayload['body'] as String?) ?? 'Dersiniz yaklaşıyor'} (Ertelendi)',
      scheduledTime: snoozeTime,
      payload: json.encode({
        ...originalPayload,
        'isSnooze': true,
        'snoozeCount': (originalPayload['snoozeCount'] ?? 0) + 1,
      }),
      repeatsDailyAtSameTime: false,
      // Snooze aksiyonları aynı kalsın
      androidActions: const [
        AndroidNotificationAction('attended', 'Katıldım'),
        AndroidNotificationAction('missed', 'Kaçırdım'),
        AndroidNotificationAction('snooze10', '10dk Snooze'),
      ],
    );
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
        : (reminders.first.description ?? '');

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
      repeatsDailyAtSameTime: false,
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    List<AndroidNotificationAction>? androidActions,
    bool repeatsDailyAtSameTime = false,
  }) async {
    await _ensureTimezoneInitialized();

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'attendkal_reminders',
      'Ders Hatırlatıcıları',
      channelDescription: 'Ders ve toplantı hatırlatıcıları',
      importance: Importance.high,
      priority: Priority.high,
      actions: androidActions,
      autoCancel: !repeatsDailyAtSameTime,
      ongoing: false,
      styleInformation: const BigTextStyleInformation(''),
      category: AndroidNotificationCategory.reminder,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
      categoryIdentifier: 'ATTENDKAL_CATEGORY',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // ÖNEMLİ: Tek seferlikler için null; tekrar eden (her gün aynı saat) için time
      matchDateTimeComponents: repeatsDailyAtSameTime
          ? DateTimeComponents.time
          : null,
    );
  }

  /// ----------------------
  /// HELPERS
  /// ----------------------
  int _generateNotificationId(String reminderId, int timestamp) {
    final combined = '$reminderId$timestamp';
    return combined.hashCode.abs() % 2147483647; // int32
  }

  String _generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rnd = Random().nextInt(999);
    return '${ts}_$rnd';
  }
}
