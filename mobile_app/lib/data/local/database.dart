import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Table, Column;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

// Enums
enum AttendanceStatus { present, absent, late, excused }

enum ReminderType {
  courseMorning, // Ders günü sabah hatırlatıcısı
  coursePreStart, // Dersten önce hatırlatıcı
  custom, // Serbest hatırlatıcı
}

enum RepeatType {
  once, // Tek seferlik
  daily, // Her gün
  weekly, // Her hafta
  monthly, // Her ay
}

enum NotificationActionType {
  attended, // Katıldım
  missed, // Kaçırdım
  snooze10, // 10dk snooze
  snooze30, // 30dk snooze
  snooze2h, // 2 saat snooze
}

// Type Converters
class ColorConverter extends TypeConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromSql(int fromDb) => Color(fromDb);

  @override
  int toSql(Color value) => value.value;
}

class JsonConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) => json.decode(fromDb);

  @override
  String toSql(Map<String, dynamic> value) => json.encode(value);
}

// Tables
class Courses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get teacher => text().nullable()();
  TextColumn get location => text().nullable()();
  IntColumn get color => integer().map(const ColorConverter())();
  TextColumn get note => text().nullable()();
  IntColumn get maxAbsences => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Meetings extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text().references(Courses, #id)();
  IntColumn get weekday => integer()(); // 1=Monday, 7=Sunday
  TextColumn get startHHmm => text()(); // "09:00"
  IntColumn get durationMin => integer()();
  TextColumn get location => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text().references(Courses, #id)();
  IntColumn get startUtc => integer()();
  IntColumn get endUtc => integer()();
  TextColumn get note => text().nullable()();
  BoolColumn get wasCancelled => boolean().withDefault(const Constant(false))();
  TextColumn get cancellationReason => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Attendance extends Table {
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get userId => text()();
  IntColumn get status => intEnum<AttendanceStatus>()();
  IntColumn get timestamp => integer()();
  TextColumn get note => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {sessionId, userId};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {key};
}

class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get operation => text()();
  TextColumn get tableNameValue => text()();
  TextColumn get recordId => text()();
  TextColumn get data => text().map(const JsonConverter())();
  IntColumn get createdAt => integer()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get lastRetryAt => integer().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get type => intEnum<ReminderType>()();
  TextColumn get courseId =>
      text().nullable().references(Courses, #id)(); // null for custom reminders
  IntColumn get scheduledTime => integer()(); // UTC timestamp
  IntColumn get repeatType => intEnum<RepeatType>()();
  IntColumn get repeatInterval => integer().withDefault(
    const Constant(1),
  )(); // for weekly: 1=every week, 2=every 2 weeks
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get notificationId =>
      integer().nullable()(); // for cancelling notifications
  TextColumn get metadata => text().nullable().map(
    const JsonConverter(),
  )(); // extra data like snooze count
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class NotificationActions extends Table {
  TextColumn get id => text()();
  TextColumn get reminderId => text().references(Reminders, #id)();
  IntColumn get actionType => intEnum<NotificationActionType>()();
  IntColumn get timestamp => integer()();
  TextColumn get sessionId =>
      text().nullable().references(Sessions, #id)(); // for attendance actions
  TextColumn get metadata =>
      text().nullable().map(const JsonConverter())(); // extra data
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

// Database
@DriftDatabase(
  tables: [
    Courses,
    Meetings,
    Sessions,
    Attendance,
    Settings,
    SyncQueue,
    Reminders,
    NotificationActions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static final AppDatabase _instance = AppDatabase._();
  static AppDatabase get instance => _instance;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        // Create indexes for performance
        await customStatement('''
          CREATE INDEX idx_sessions_course_start 
          ON sessions(course_id, start_utc);
        ''');

        await customStatement('''
          CREATE INDEX idx_attendance_status 
          ON attendance(status);
        ''');
      },
    );
  }

  // Course operations
  Future<List<Course>> getAllCourses() => select(courses).get();

  Future<Course?> getCourseById(String id) =>
      (select(courses)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insertCourse(CoursesCompanion course) =>
      into(courses).insert(course);

  Future<bool> updateCourse(CoursesCompanion course) =>
      update(courses).replace(course);

  Future<int> deleteCourse(String id) =>
      (delete(courses)..where((c) => c.id.equals(id))).go();

  // Meeting operations
  Future<List<Meeting>> getMeetingsForCourse(String courseId) =>
      (select(meetings)..where((m) => m.courseId.equals(courseId))).get();

  Future<int> insertMeeting(MeetingsCompanion meeting) =>
      into(meetings).insert(meeting);

  Future<bool> updateMeeting(MeetingsCompanion meeting) =>
      update(meetings).replace(meeting);

  Future<int> deleteMeeting(String id) =>
      (delete(meetings)..where((m) => m.id.equals(id))).go();

  // Session operations
  Future<List<Session>> getSessionsForCourse(String courseId) =>
      (select(sessions)..where((s) => s.courseId.equals(courseId))).get();

  Future<Session?> getSessionById(String id) =>
      (select(sessions)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<List<Session>> getSessionsInDateRange(DateTime start, DateTime end) {
    final startUtc = start.millisecondsSinceEpoch;
    final endUtc = end.millisecondsSinceEpoch;
    return (select(
      sessions,
    )..where((s) => s.startUtc.isBetweenValues(startUtc, endUtc))).get();
  }

  Future<int> insertSession(SessionsCompanion session) =>
      into(sessions).insert(session);

  Future<bool> updateSession(SessionsCompanion session) =>
      update(sessions).replace(session);

  Future<int> deleteSession(String id) =>
      (delete(sessions)..where((s) => s.id.equals(id))).go();

  // Attendance operations
  Future<AttendanceData?> getAttendanceForSession(String sessionId) => (select(
    attendance,
  )..where((a) => a.sessionId.equals(sessionId))).getSingleOrNull();

  Future<int> insertAttendance(AttendanceCompanion attendanceRecord) =>
      into(attendance).insert(attendanceRecord);

  Future<bool> updateAttendance(AttendanceCompanion attendanceRecord) =>
      update(attendance).replace(attendanceRecord);

  Future<int> deleteAttendance(String sessionId) =>
      (delete(attendance)..where((a) => a.sessionId.equals(sessionId))).go();

  // Settings operations
  Future<String?> getSetting(String key) async {
    final setting = await (select(
      settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return setting?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // Sync queue operations
  Future<void> addToSyncQueue(
    String operation,
    String tableName,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    await into(syncQueue).insert(
      SyncQueueCompanion.insert(
        id: 'sync_${DateTime.now().millisecondsSinceEpoch}_${recordId}',
        operation: operation,
        tableNameValue: tableName,
        recordId: recordId,
        data: data,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // Course summary with attendance stats
  Future<Map<String, dynamic>> getCourseSummary(String courseId) async {
    final course = await getCourseById(courseId);
    if (course == null) return {};

    final sessionsList = await getSessionsForCourse(courseId);
    final totalSessions = sessionsList.length;

    int attendedSessions = 0;
    int absentSessions = 0;

    for (final session in sessionsList) {
      final attendanceRecord = await getAttendanceForSession(session.id);
      if (attendanceRecord?.status == AttendanceStatus.present) {
        attendedSessions++;
      } else if (attendanceRecord?.status == AttendanceStatus.absent) {
        absentSessions++;
      }
    }

    final attendanceRate = totalSessions > 0
        ? attendedSessions / totalSessions
        : 0.0;
    final remainingAbsences = course.maxAbsences - absentSessions;
    final isAtRisk = remainingAbsences <= 0;

    return {
      'course': course,
      'totalSessions': totalSessions,
      'attendedSessions': attendedSessions,
      'absentSessions': absentSessions,
      'attendanceRate': attendanceRate,
      'remainingAbsences': remainingAbsences,
      'isAtRisk': isAtRisk,
    };
  }

  // Get all meetings
  Future<List<Meeting>> getAllMeetings() async {
    return await select(meetings).get();
  }

  // Get all attendances
  Future<List<AttendanceData>> getAllAttendances() async {
    return await select(attendance).get();
  }

  Future<List<Map<String, dynamic>>> getAllCoursesSummary() async {
    final coursesList = await getAllCourses();
    final summaries = <Map<String, dynamic>>[];

    for (final course in coursesList) {
      final summary = await getCourseSummary(course.id);
      summaries.add(summary);
    }

    return summaries;
  }

  // Reminder operations
  Future<List<Reminder>> getAllReminders() => select(reminders).get();

  Future<List<Reminder>> getActiveReminders() =>
      (select(reminders)..where((r) => r.isActive.equals(true))).get();

  Future<List<Reminder>> getRemindersByTimeRange(int startTime, int endTime) =>
      (select(reminders)
            ..where((r) => r.scheduledTime.isBetweenValues(startTime, endTime))
            ..where((r) => r.isActive.equals(true))
            ..orderBy([(r) => OrderingTerm(expression: r.scheduledTime)]))
          .get();

  Future<List<Reminder>> getRemindersByCourse(String courseId) =>
      (select(reminders)..where((r) => r.courseId.equals(courseId))).get();

  Future<int> insertReminder(RemindersCompanion reminder) =>
      into(reminders).insert(reminder);

  Future<bool> updateReminder(RemindersCompanion reminder) =>
      update(reminders).replace(reminder);

  Future<int> deleteReminder(String id) =>
      (delete(reminders)..where((r) => r.id.equals(id))).go();

  Future<void> deactivateReminder(String id) async {
    await (update(reminders)..where((r) => r.id.equals(id))).write(
      RemindersCompanion(isActive: const Value(false)),
    );
  }

  // Notification Actions operations
  Future<List<NotificationAction>> getNotificationActions() =>
      select(notificationActions).get();

  Future<int> insertNotificationAction(NotificationActionsCompanion action) =>
      into(notificationActions).insert(action);

  Future<List<NotificationAction>> getActionsByReminder(String reminderId) =>
      (select(
        notificationActions,
      )..where((a) => a.reminderId.equals(reminderId))).get();

  // Progress operations
  Future<Map<String, dynamic>> getOverallProgress() async {
    final coursesList = await getAllCourses();
    final allAttendances = await getAllAttendances();
    final allSessions = await select(sessions).get();

    int totalSessions = allSessions.length;
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalExcused = 0;
    int totalRemainingAbsences = 0;

    for (final course in coursesList) {
      final courseSessions = allSessions.where((s) => s.courseId == course.id);
      int courseAbsent = 0;

      for (final session in courseSessions) {
        final attendance = allAttendances.firstWhere(
          (a) => a.sessionId == session.id,
          orElse: () => AttendanceData(
            sessionId: session.id,
            userId: '',
            status: AttendanceStatus.absent,
            timestamp: 0,
            createdAt: 0,
            updatedAt: 0,
          ),
        );

        switch (attendance.status) {
          case AttendanceStatus.present:
            totalPresent++;
            break;
          case AttendanceStatus.absent:
            totalAbsent++;
            courseAbsent++;
            break;
          case AttendanceStatus.excused:
            totalExcused++;
            break;
          case AttendanceStatus.late:
            totalPresent++; // Late counts as present
            break;
        }
      }

      totalRemainingAbsences += (course.maxAbsences - courseAbsent).clamp(
        0,
        course.maxAbsences,
      );
    }

    final attendanceRate = totalSessions > 0
        ? (totalPresent / totalSessions) * 100
        : 0.0;

    return {
      'totalSessions': totalSessions,
      'totalPresent': totalPresent,
      'totalAbsent': totalAbsent,
      'totalExcused': totalExcused,
      'attendanceRate': attendanceRate,
      'totalRemainingAbsences': totalRemainingAbsences,
    };
  }

  Future<List<Map<String, dynamic>>> getCourseProgressList() async {
    final coursesList = await getAllCourses();
    final progressList = <Map<String, dynamic>>[];

    for (final course in coursesList) {
      final courseSessions = await getSessionsForCourse(course.id);
      int present = 0;
      int absent = 0;
      int excused = 0;

      for (final session in courseSessions) {
        final attendance = await getAttendanceForSession(session.id);
        if (attendance != null) {
          switch (attendance.status) {
            case AttendanceStatus.present:
            case AttendanceStatus.late:
              present++;
              break;
            case AttendanceStatus.absent:
              absent++;
              break;
            case AttendanceStatus.excused:
              excused++;
              break;
          }
        }
      }

      final totalSessions = courseSessions.length;
      final attendanceRate = totalSessions > 0
          ? (present / totalSessions) * 100
          : 0.0;
      final remainingAbsences = (course.maxAbsences - absent).clamp(
        0,
        course.maxAbsences,
      );

      String statusIcon;
      if (remainingAbsences == 0) {
        statusIcon = '❌'; // At risk
      } else if (remainingAbsences <= 2) {
        statusIcon = '⚠️'; // Warning
      } else {
        statusIcon = '✅'; // Safe
      }

      progressList.add({
        'course': course,
        'totalSessions': totalSessions,
        'present': present,
        'absent': absent,
        'excused': excused,
        'attendanceRate': attendanceRate,
        'remainingAbsences': remainingAbsences,
        'statusIcon': statusIcon,
      });
    }

    return progressList;
  }

  Future<List<Map<String, dynamic>>> getWeeklyTrend({int weeks = 8}) async {
    final now = DateTime.now();
    final weeklyData = <Map<String, dynamic>>[];

    for (int i = weeks - 1; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final weekSessions = await getSessionsInDateRange(
        DateTime(weekStart.year, weekStart.month, weekStart.day),
        DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59),
      );

      int weekPresent = 0;
      int weekTotal = weekSessions.length;

      for (final session in weekSessions) {
        final attendance = await getAttendanceForSession(session.id);
        if (attendance != null &&
            (attendance.status == AttendanceStatus.present ||
                attendance.status == AttendanceStatus.late)) {
          weekPresent++;
        }
      }

      final weekRate = weekTotal > 0 ? (weekPresent / weekTotal) * 100 : 0.0;

      weeklyData.add({
        'weekStart': weekStart,
        'weekEnd': weekEnd,
        'totalSessions': weekTotal,
        'presentSessions': weekPresent,
        'attendanceRate': weekRate,
        'weekLabel': '${weekStart.day}/${weekStart.month}',
      });
    }

    return weeklyData;
  }

  Future<List<Map<String, dynamic>>> getDailyHeatmap({int days = 30}) async {
    final now = DateTime.now();
    final dailyData = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);

      final daySessions = await getSessionsInDateRange(dayStart, dayEnd);

      int dayPresent = 0;
      int dayTotal = daySessions.length;

      for (final session in daySessions) {
        final attendance = await getAttendanceForSession(session.id);
        if (attendance != null &&
            (attendance.status == AttendanceStatus.present ||
                attendance.status == AttendanceStatus.late)) {
          dayPresent++;
        }
      }

      double intensity = 0.0;
      if (dayTotal > 0) {
        intensity = dayPresent / dayTotal;
      }

      dailyData.add({
        'date': day,
        'totalSessions': dayTotal,
        'presentSessions': dayPresent,
        'intensity': intensity, // 0.0 - 1.0
        'weekday': day.weekday,
      });
    }

    return dailyData;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'attendkal.db'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
