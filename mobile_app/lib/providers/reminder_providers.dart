import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
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

      int startTime, endTime;

      switch (timeRange.type) {
        case TimeRangeType.upcoming:
          startTime = now.millisecondsSinceEpoch;
          endTime = now.add(const Duration(hours: 48)).millisecondsSinceEpoch;
          break;
        case TimeRangeType.future:
          startTime = now.add(const Duration(hours: 48)).millisecondsSinceEpoch;
          endTime = now
              .add(const Duration(days: 365))
              .millisecondsSinceEpoch; // Next year
          break;
        case TimeRangeType.past:
          startTime = now
              .subtract(const Duration(days: 365))
              .millisecondsSinceEpoch; // Last year
          endTime = now.millisecondsSinceEpoch;
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
        title: title,
        description: description != null
            ? Value(description)
            : const Value.absent(),
        type: type,
        courseId: courseId != null ? Value(courseId) : const Value.absent(),
        scheduledTime: scheduledTime.millisecondsSinceEpoch,
        repeatType: repeatType,
        repeatInterval: Value(repeatInterval),
        metadata: metadata != null ? Value(metadata) : const Value.absent(),
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
      await _db.addToSyncQueue('insert', 'reminders', reminderId, {
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
      });

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

      final reminder = RemindersCompanion(
        id: Value(reminderId),
        title: Value(title),
        description: description != null
            ? Value(description)
            : const Value.absent(),
        type: Value(type),
        courseId: courseId != null ? Value(courseId) : const Value.absent(),
        scheduledTime: Value(scheduledTime.millisecondsSinceEpoch),
        repeatType: Value(repeatType),
        repeatInterval: Value(repeatInterval),
        metadata: metadata != null ? Value(metadata) : const Value.absent(),
        updatedAt: Value(now),
      );

      await _db.updateReminder(reminder);

      // Reschedule notification
      final updatedReminder = await _getReminderById(reminderId);
      if (updatedReminder != null) {
        // Cancel old notification if exists
        if (updatedReminder.notificationId != null) {
          await _notificationService.cancelNotification(
            updatedReminder.notificationId!,
          );
        }
        // Schedule new notification
        await _notificationService.scheduleReminder(updatedReminder);
      }

      // Add to sync queue
      await _db.addToSyncQueue('update', 'reminders', reminderId, {
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
      });

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
      await _db.addToSyncQueue('delete', 'reminders', reminderId, {
        'id': reminderId,
      });

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
      final reminder = RemindersCompanion(
        id: Value(reminderId),
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      );

      await _db.updateReminder(reminder);

      // Handle notification scheduling
      final updatedReminder = await _getReminderById(reminderId);
      if (updatedReminder != null) {
        if (isActive) {
          await _notificationService.scheduleReminder(updatedReminder);
        } else if (updatedReminder.notificationId != null) {
          await _notificationService.cancelNotification(
            updatedReminder.notificationId!,
          );
        }
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
      print('Error rescheduling course reminders: $error');
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
