import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../data/local/db.dart';
import '../providers/courses_providers.dart';

// Data export/import service
class DataService {
  final AppDatabase _database;

  DataService(this._database);

  // Export all data to JSON
  Future<Map<String, dynamic>> exportAllData() async {
    final courses = await _database.getAllCourses();
    final meetings = await _database.getAllMeetings();
    final sessions = await _database.select(_database.sessions).get();
    final attendances = await _database.getAllAttendances();
    final reminders = await _database.getAllReminders();

    // Settings export
    final settingsKeys = [
      'timezone',
      'morningHour',
      'minutesBeforeClass',
      'includeClassNotesInNotifications',
      'language',
    ];
    final settings = <String, String>{};
    for (final key in settingsKeys) {
      final value = await _database.getSetting(key);
      if (value != null) {
        settings[key] = value;
      }
    }

    return {
      'exportVersion': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'data': {
        'courses': courses.map((c) => _courseToJson(c)).toList(),
        'meetings': meetings.map((m) => _meetingToJson(m)).toList(),
        'sessions': sessions.map((s) => _sessionToJson(s)).toList(),
        'attendances': attendances.map((a) => _attendanceToJson(a)).toList(),
        'reminders': reminders.map((r) => _reminderToJson(r)).toList(),
        'settings': settings,
      },
    };
  }

  // Import data from JSON
  Future<void> importAllData(Map<String, dynamic> jsonData) async {
    if (jsonData['exportVersion'] != '1.0') {
      throw Exception('Desteklenmeyen export versiyonu');
    }

    final data = jsonData['data'] as Map<String, dynamic>;

    // Clear existing data
    await _database.customStatement('DELETE FROM attendance');
    await _database.customStatement('DELETE FROM sessions');
    await _database.customStatement('DELETE FROM meetings');
    await _database.customStatement('DELETE FROM courses');
    await _database.customStatement('DELETE FROM reminders');

    // Import courses
    if (data['courses'] != null) {
      for (final courseJson in data['courses']) {
        await _database.insertCourse(_courseFromJson(courseJson));
      }
    }

    // Import meetings
    if (data['meetings'] != null) {
      for (final meetingJson in data['meetings']) {
        await _database.insertMeeting(_meetingFromJson(meetingJson));
      }
    }

    // Import sessions
    if (data['sessions'] != null) {
      for (final sessionJson in data['sessions']) {
        await _database.insertSession(_sessionFromJson(sessionJson));
      }
    }

    // Import attendances
    if (data['attendances'] != null) {
      for (final attendanceJson in data['attendances']) {
        await _database.insertAttendance(_attendanceFromJson(attendanceJson));
      }
    }

    // Import reminders
    if (data['reminders'] != null) {
      for (final reminderJson in data['reminders']) {
        await _database.insertReminder(_reminderFromJson(reminderJson));
      }
    }

    // Import settings
    if (data['settings'] != null) {
      final settings = data['settings'] as Map<String, dynamic>;
      for (final entry in settings.entries) {
        await _database.setSetting(entry.key, entry.value.toString());
      }
    }
  }

  // Export to file and get path
  Future<String> exportToFile() async {
    final data = await exportAllData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'attendkal_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(jsonString);

    return file.path;
  }

  // Reset all data
  Future<void> resetAllData() async {
    // Clear all tables
    await _database.customStatement('DELETE FROM attendance');
    await _database.customStatement('DELETE FROM sessions');
    await _database.customStatement('DELETE FROM meetings');
    await _database.customStatement('DELETE FROM courses');
    await _database.customStatement('DELETE FROM reminders');
    await _database.customStatement('DELETE FROM notification_actions');
    await _database.customStatement('DELETE FROM sync_queue');
    await _database.customStatement('DELETE FROM settings');
  }

  // Convert models to JSON
  Map<String, dynamic> _courseToJson(Course course) {
    return {
      'id': course.id,
      'name': course.name,
      'code': course.code,
      'teacher': course.teacher,
      'location': course.location,
      // ignore: deprecated_member_use
      'color': course.color.value,
      'note': course.note,
      'maxAbsences': course.maxAbsences,
      'createdAt': course.createdAt,
      'updatedAt': course.updatedAt,
    };
  }

  Map<String, dynamic> _meetingToJson(Meeting meeting) {
    return {
      'id': meeting.id,
      'courseId': meeting.courseId,
      'weekday': meeting.weekday,
      'startHHmm': meeting.startHHmm,
      'durationMin': meeting.durationMin,
      'location': meeting.location,
      'note': meeting.note,
    };
  }

  Map<String, dynamic> _sessionToJson(Session session) {
    return {
      'id': session.id,
      'courseId': session.courseId,
      'startUtc': session.startUtc,
      'endUtc': session.endUtc,
      'durationMin': session.durationMin,
      'source': session.source,
      'generatedFromMeetingId': session.generatedFromMeetingId,
      'note': session.note,
      'wasCancelled': session.wasCancelled,
      'cancellationReason': session.cancellationReason,
      'createdAt': session.createdAt,
      'updatedAt': session.updatedAt,
    };
  }

  Map<String, dynamic> _attendanceToJson(AttendanceData attendance) {
    return {
      'id': attendance.id,
      'sessionId': attendance.sessionId,
      'userId': attendance.userId,
      'status': attendance.status.name,
      'timestamp': attendance.timestamp,
      'markedAt': attendance.markedAt,
      'note': attendance.note,
      'latitude': attendance.latitude,
      'longitude': attendance.longitude,
      'createdAt': attendance.createdAt,
      'updatedAt': attendance.updatedAt,
    };
  }

  Map<String, dynamic> _reminderToJson(Reminder reminder) {
    return {
      'id': reminder.id,
      'userId': reminder.userId,
      'title': reminder.title,
      'description': reminder.description,
      'type': reminder.type.name,
      'courseId': reminder.courseId,
      'scheduledTime': reminder.scheduledTime,
      'repeatType': reminder.repeatType.name,
      'repeatInterval': reminder.repeatInterval,
      'isActive': reminder.isActive,
      'notificationId': reminder.notificationId,
      'metadata': reminder.metadata,
      'morningOfClass': reminder.morningOfClass,
      'minutesBefore': reminder.minutesBefore,
      'thresholdAlerts': reminder.thresholdAlerts,
      'cron': reminder.cron,
      'enabled': reminder.enabled,
      'createdAt': reminder.createdAt,
      'updatedAt': reminder.updatedAt,
    };
  }

  // Convert JSON to models
  CoursesCompanion _courseFromJson(Map<String, dynamic> json) {
    return CoursesCompanion.insert(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      teacher: Value(json['teacher']),
      location: Value(json['location']),
      color: Color(json['color']),
      note: Value(json['note']),
      maxAbsences: json['maxAbsences'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  MeetingsCompanion _meetingFromJson(Map<String, dynamic> json) {
    return MeetingsCompanion.insert(
      id: json['id'],
      courseId: json['courseId'],
      weekday: json['weekday'],
      startHHmm: json['startHHmm'],
      durationMin: json['durationMin'],
      location: Value(json['location']),
      note: Value(json['note']),
    );
  }

  SessionsCompanion _sessionFromJson(Map<String, dynamic> json) {
    return SessionsCompanion.insert(
      id: json['id'],
      courseId: json['courseId'],
      startUtc: json['startUtc'],
      durationMin: json['durationMin'] ?? 120, // Default 2 hours if missing
      source: json['source'] ?? 'import', // Default source
      endUtc: Value(json['endUtc']),
      generatedFromMeetingId: Value(json['generatedFromMeetingId']),
      note: Value(json['note']),
      wasCancelled: Value(json['wasCancelled'] ?? false),
      cancellationReason: Value(json['cancellationReason']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  AttendanceCompanion _attendanceFromJson(Map<String, dynamic> json) {
    return AttendanceCompanion.insert(
      id: json['id'] as String? ?? const Uuid().v4(),
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      timestamp: json['timestamp'] as int,
      markedAt:
          json['markedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      note: Value(json['note'] as String?),
      latitude: Value(json['latitude'] as double?),
      longitude: Value(json['longitude'] as double?),
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
    );
  }

  RemindersCompanion _reminderFromJson(Map<String, dynamic> json) {
    return RemindersCompanion.insert(
      id: json['id'],
      userId: json['userId'] as String? ?? '',
      title: json['title'],
      description: Value(json['description']),
      type: ReminderType.values.byName(json['type']),
      courseId: Value(json['courseId']),
      scheduledTime: json['scheduledTime'],
      repeatType: RepeatType.values.byName(json['repeatType']),
      repeatInterval: Value(json['repeatInterval'] ?? 1),
      isActive: Value(json['isActive'] ?? true),
      notificationId: Value(json['notificationId']),
      metadata: Value(json['metadata']),
      morningOfClass: json['morningOfClass'] as bool? ?? false,
      minutesBefore: json['minutesBefore'] as int? ?? 15,
      thresholdAlerts: json['thresholdAlerts'] as bool? ?? false,
      cron: Value(json['cron']),
      enabled: Value(json['enabled'] ?? true),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

// Data service provider
final dataServiceProvider = Provider<DataService>((ref) {
  final database = AppDatabase.instance;
  return DataService(database);
});

// Export/Import state
class DataOperationState {
  final bool isLoading;
  final String? error;
  final String? message;

  const DataOperationState({this.isLoading = false, this.error, this.message});

  DataOperationState copyWith({
    bool? isLoading,
    String? error,
    String? message,
  }) {
    return DataOperationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
    );
  }
}

// Data operations notifier
class DataOperationsNotifier extends StateNotifier<DataOperationState> {
  final DataService _dataService;
  final Ref _ref;

  DataOperationsNotifier(this._dataService, this._ref)
    : super(const DataOperationState());

  Future<String> exportData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final filePath = await _dataService.exportToFile();
      state = state.copyWith(
        isLoading: false,
        message: 'Veriler başarıyla dışa aktarıldı: $filePath',
      );
      return filePath;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Dışa aktarma hatası: $e',
      );
      rethrow;
    }
  }

  Future<void> importData(String jsonString) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      await _dataService.importAllData(jsonData);

      // Invalidate all providers
      _ref.invalidate(coursesProvider);

      state = state.copyWith(
        isLoading: false,
        message: 'Veriler başarıyla içe aktarıldı',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'İçe aktarma hatası: $e');
    }
  }

  Future<void> resetAllData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _dataService.resetAllData();

      // Invalidate all providers
      _ref.invalidate(coursesProvider);

      state = state.copyWith(
        isLoading: false,
        message: 'Tüm veriler sıfırlandı',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Sıfırlama hatası: $e');
    }
  }

  void clearMessage() {
    state = state.copyWith(message: null, error: null);
  }
}

// Data operations provider
final dataOperationsProvider =
    StateNotifierProvider<DataOperationsNotifier, DataOperationState>((ref) {
      final dataService = ref.watch(dataServiceProvider);
      return DataOperationsNotifier(dataService, ref);
    });
