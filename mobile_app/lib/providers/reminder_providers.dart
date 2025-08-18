import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../data/local/db.dart';
import '../services/notification_service.dart';

// Database provider
final reminderDatabaseProvider = Provider<AppDatabase>(
  (ref) => AppDatabase.instance,
);

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

// Reminders by time range provider (for tab filtering)
final remindersByTimeRangeProvider =
    FutureProvider.family<List<Reminder>, TimeRange>((ref, timeRange) async {
      final db = ref.watch(reminderDatabaseProvider);
      final now = DateTime.now();

      DateTime startTime, endTime;

      switch (timeRange.type) {
        case TimeRangeType.upcoming:
          startTime = now;
          endTime = now.add(const Duration(hours: 48));
          break;
        case TimeRangeType.future:
          startTime = now.add(const Duration(hours: 48));
          endTime = now.add(const Duration(days: 365)); // Next year
          break;
        case TimeRangeType.past:
          startTime = now.subtract(const Duration(days: 365)); // Last year
          endTime = now;
          break;
      }

      return await db.getRemindersByTimeRange(startTime, endTime);
    });

// Active reminders provider
final activeRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final db = ref.watch(reminderDatabaseProvider);
  return await db.getActiveReminders();
});

// Reminders by course provider
final remindersByCourseProvider = FutureProvider.family<List<Reminder>, String>(
  (ref, courseId) async {
    final db = ref.watch(reminderDatabaseProvider);
    return await db.getRemindersByCourse(courseId);
  },
);

// Reminder notifier for CRUD operations
class ReminderNotifier extends StateNotifier<AsyncValue<List<Reminder>>> {
  final AppDatabase _db;
  final Ref _ref;
  final NotificationService _notificationService;

  ReminderNotifier(this._db, this._ref, this._notificationService)
    : super(const AsyncValue.loading()) {
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final reminders = await _db.getAllReminders();
      state = AsyncValue.data(reminders);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Reminder> addReminder({
    required String title,
    String? description,
    required ReminderType type,
    String? courseId,
    required DateTime scheduledTime,
    required RepeatType repeatType,
    int repeatInterval = 1,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final reminderId = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      final reminder = RemindersCompanion.insert(
        id: reminderId,
        userId: 'current_user', // TODO: Get from auth service
        title: title,
        description: description != null
            ? Value(description)
            : const Value.absent(),
        type: type,
        courseId: courseId != null ? Value(courseId) : const Value.absent(),
        scheduledTime: scheduledTime.millisecondsSinceEpoch,
        repeatType: repeatType,
        repeatInterval: Value(repeatInterval),
        metadata: metadata != null
            ? Value(json.encode(metadata))
            : const Value.absent(),
        morningOfClass: false, // Default value
        minutesBefore: 0, // Default value
        thresholdAlerts: false, // Default value
        createdAt: now,
        updatedAt: now,
      );

      await _db.insertReminder(reminder);

      // Schedule notification
      final createdReminder = await _getReminderById(reminderId);
      if (createdReminder != null) {
        await _notificationService.scheduleReminder(createdReminder);
      }

      // Add to sync queue
      await _db.addToSyncQueue(
        SyncQueueCompanion.insert(
          entity: 'reminders',
          entityId: reminderId,
          op: 'insert',
          payloadJson: json.encode({
            'id': reminderId,
            'title': title,
            'description': description,
            'type': type.name,
            'courseId': courseId,
            'scheduledTime': scheduledTime.millisecondsSinceEpoch,
            'repeatType': repeatType.name,
            'repeatInterval': repeatInterval,
            'metadata': metadata,
            'createdAt': now,
            'updatedAt': now,
          }),
          createdAt: now,
        ),
      );

      // Invalidate providers
      _ref.invalidate(activeRemindersProvider);
      _ref.invalidate(remindersByTimeRangeProvider);
      if (courseId != null) {
        _ref.invalidate(remindersByCourseProvider(courseId));
      }

      _loadReminders();
      return createdReminder!;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateReminder({
    required String reminderId,
    required String title,
    String? description,
    required ReminderType type,
    String? courseId,
    required DateTime scheduledTime,
    required RepeatType repeatType,
    int repeatInterval = 1,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Get existing reminder and create updated version
      final existingReminder = await _getReminderById(reminderId);
      if (existingReminder == null) return;

      final updatedReminder = Reminder(
        id: reminderId,
        userId: existingReminder.userId,
        title: title,
        description: description,
        type: type,
        courseId: courseId,
        scheduledTime: scheduledTime.millisecondsSinceEpoch,
        repeatType: repeatType,
        repeatInterval: repeatInterval,
        isActive: existingReminder.isActive,
        notificationId: existingReminder.notificationId,
        metadata: metadata != null ? json.encode(metadata) : null,
        morningOfClass: existingReminder.morningOfClass,
        minutesBefore: existingReminder.minutesBefore,
        thresholdAlerts: existingReminder.thresholdAlerts,
        cron: existingReminder.cron,
        enabled: existingReminder.enabled,
        createdAt: existingReminder.createdAt,
        updatedAt: now,
      );

      await _db.updateReminder(updatedReminder);

      // Reschedule notification
      // Cancel old notification if exists
      if (updatedReminder.notificationId != null) {
        await _notificationService.cancelNotification(
          updatedReminder.notificationId!,
        );
      }
      // Schedule new notification
      await _notificationService.scheduleReminder(updatedReminder);

      // Add to sync queue
      await _db.addToSyncQueue(
        SyncQueueCompanion.insert(
          entity: 'reminders',
          entityId: reminderId,
          op: 'update',
          payloadJson: json.encode({
            'id': reminderId,
            'title': title,
            'description': description,
            'type': type.name,
            'courseId': courseId,
            'scheduledTime': scheduledTime.millisecondsSinceEpoch,
            'repeatType': repeatType.name,
            'repeatInterval': repeatInterval,
            'metadata': metadata,
            'updatedAt': now,
          }),
          createdAt: now,
        ),
      );

      // Invalidate providers
      _ref.invalidate(activeRemindersProvider);
      _ref.invalidate(remindersByTimeRangeProvider);
      if (courseId != null) {
        _ref.invalidate(remindersByCourseProvider(courseId));
      }

      _loadReminders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      // Get reminder before deletion to cancel notification
      final reminder = await _getReminderById(reminderId);
      if (reminder?.notificationId != null) {
        await _notificationService.cancelNotification(
          reminder!.notificationId!,
        );
      }

      await _db.deleteReminder(reminderId);

      // Add to sync queue
      await _db.addToSyncQueue(
        SyncQueueCompanion.insert(
          entity: 'reminders',
          entityId: reminderId,
          op: 'delete',
          payloadJson: json.encode({'id': reminderId}),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Invalidate providers
      _ref.invalidate(activeRemindersProvider);
      _ref.invalidate(remindersByTimeRangeProvider);
      if (reminder?.courseId != null) {
        _ref.invalidate(remindersByCourseProvider(reminder!.courseId!));
      }

      _loadReminders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleReminderActive(String reminderId, bool isActive) async {
    try {
      // Get existing reminder first
      final existingReminder = await _getReminderById(reminderId);
      if (existingReminder == null) return;

      // Create updated reminder
      final updatedReminder = Reminder(
        id: existingReminder.id,
        userId: existingReminder.userId,
        title: existingReminder.title,
        description: existingReminder.description,
        type: existingReminder.type,
        courseId: existingReminder.courseId,
        scheduledTime: existingReminder.scheduledTime,
        repeatType: existingReminder.repeatType,
        repeatInterval: existingReminder.repeatInterval,
        isActive: isActive,
        notificationId: existingReminder.notificationId,
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

      // Handle notification scheduling
      if (isActive) {
        await _notificationService.scheduleReminder(updatedReminder);
      } else if (updatedReminder.notificationId != null) {
        await _notificationService.cancelNotification(
          updatedReminder.notificationId!,
        );
      }

      // Invalidate providers
      _ref.invalidate(activeRemindersProvider);
      _ref.invalidate(remindersByTimeRangeProvider);

      _loadReminders();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Reminder?> _getReminderById(String id) async {
    final reminders = await _db.getAllReminders();
    try {
      return reminders.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Reschedule all reminders for a course when course data changes
  Future<void> rescheduleCourseReminders(String courseId) async {
    try {
      final courseReminders = await _db.getRemindersByCourse(courseId);

      for (final reminder in courseReminders) {
        if (reminder.notificationId != null) {
          await _notificationService.cancelNotification(
            reminder.notificationId!,
          );
        }
        await _notificationService.scheduleReminder(reminder);
      }
    } catch (error) {
      // Log error but don't fail
      debugPrint('Error rescheduling course reminders: $error');
    }
  }
}

final reminderNotifierProvider =
    StateNotifierProvider<ReminderNotifier, AsyncValue<List<Reminder>>>((ref) {
      final db = ref.watch(reminderDatabaseProvider);
      final notificationService = ref.watch(notificationServiceProvider);
      return ReminderNotifier(db, ref, notificationService);
    });

// Time range data classes
enum TimeRangeType { upcoming, future, past }

class TimeRange {
  final TimeRangeType type;

  const TimeRange(this.type);

  static const upcoming = TimeRange(TimeRangeType.upcoming);
  static const future = TimeRange(TimeRangeType.future);
  static const past = TimeRange(TimeRangeType.past);
}

// Notification scheduler provider - for background work
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return NotificationScheduler(notificationService);
});

class NotificationScheduler {
  final NotificationService _notificationService;

  NotificationScheduler(this._notificationService);

  Future<void> scheduleUpcomingNotifications() async {
    await _notificationService.scheduleUpcomingNotifications();
  }

  Future<void> initializeBackgroundWork() async {
    await _notificationService.initializeBackgroundWork();
  }
}
