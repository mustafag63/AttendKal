import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Table, Column;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'db.g.dart';

// Enums
enum AttendanceStatus { present, absent, excused }

enum NotificationActionType { attended, missed, snooze10, snooze30, snooze2h }

// Type Converters
class ColorConverter extends TypeConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromSql(int fromDb) {
    return Color(fromDb);
  }

  @override
  int toSql(Color value) {
    return value.value;
  }
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
  Set<Column> get primaryKey => {id};
}

class Meetings extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text().references(Courses, #id)();
  IntColumn get weekday => integer()();
  TextColumn get startHHmm => text()();
  IntColumn get durationMin => integer()();
  TextColumn get location => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text().references(Courses, #id)();
  IntColumn get startUtc => integer()();
  IntColumn get durationMin => integer()();
  TextColumn get source => text()();
  TextColumn get generatedFromMeetingId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Attendance extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().unique().references(Sessions, #id)();
  IntColumn get status => intEnum<AttendanceStatus>()();
  TextColumn get note => text().nullable()();
  IntColumn get markedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get courseId => text().nullable()();
  TextColumn get title => text()();
  BoolColumn get morningOfClass => boolean()();
  IntColumn get minutesBefore => integer()();
  BoolColumn get thresholdAlerts => boolean()();
  TextColumn get cron => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get op => text()();
  TextColumn get payloadJson => text()();
  IntColumn get createdAt => integer()();
}

@DriftDatabase(
  tables: [
    Courses,
    Meetings,
    Sessions,
    Attendance,
    Reminders,
    Settings,
    SyncQueue,
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

        await customStatement('''
          CREATE INDEX idx_sessions_course_start 
          ON sessions(course_id, start_utc);
        ''');

        await customStatement('''
          CREATE INDEX idx_attendance_status 
          ON attendance(status);
        ''');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Future migrations
        }
      },
    );
  }

  // Course DAO
  Future<List<Course>> getAllCourses() => select(courses).get();

  Future<Course?> getCourseById(String id) =>
      (select(courses)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insertCourse(CoursesCompanion course) =>
      into(courses).insert(course);

  Future<bool> updateCourse(Course course) => update(courses).replace(course);

  Future<int> deleteCourse(String id) =>
      (delete(courses)..where((c) => c.id.equals(id))).go();

  // Meeting DAO
  Future<List<Meeting>> getMeetingsForCourse(String courseId) =>
      (select(meetings)..where((m) => m.courseId.equals(courseId))).get();

  Future<int> insertMeeting(MeetingsCompanion meeting) =>
      into(meetings).insert(meeting);

  Future<bool> updateMeeting(Meeting meeting) =>
      update(meetings).replace(meeting);

  Future<int> deleteMeeting(String id) =>
      (delete(meetings)..where((m) => m.id.equals(id))).go();

  // Session DAO
  Future<List<Session>> getSessionsForCourse(String courseId) =>
      (select(sessions)..where((s) => s.courseId.equals(courseId))).get();

  Future<List<Session>> getTodaySessions() {
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).millisecondsSinceEpoch;
    final endOfDay = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).millisecondsSinceEpoch;

    return (select(sessions)
          ..where((s) => s.startUtc.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([(s) => OrderingTerm.asc(s.startUtc)]))
        .get();
  }

  Future<List<Session>> getUpcomingSessions({int limit = 10}) {
    final now = DateTime.now().millisecondsSinceEpoch;

    return (select(sessions)
          ..where((s) => s.startUtc.isBiggerThanValue(now))
          ..orderBy([(s) => OrderingTerm.asc(s.startUtc)])
          ..limit(limit))
        .get();
  }

  Future<int> insertSession(SessionsCompanion session) =>
      into(sessions).insert(session);

  Future<bool> updateSession(Session session) =>
      update(sessions).replace(session);

  Future<int> deleteSession(String id) =>
      (delete(sessions)..where((s) => s.id.equals(id))).go();

  // Attendance DAO
  Future<AttendanceData?> getAttendanceForSession(String sessionId) => (select(
    attendance,
  )..where((a) => a.sessionId.equals(sessionId))).getSingleOrNull();

  Future<List<AttendanceData>> getAttendanceForCourse(String courseId) async {
    final query = select(attendance).join([
      innerJoin(sessions, sessions.id.equalsExp(attendance.sessionId)),
    ])..where(sessions.courseId.equals(courseId));

    final results = await query.get();
    return results.map((row) => row.readTable(attendance)).toList();
  }

  Future<int> insertAttendance(AttendanceCompanion attendanceRecord) =>
      into(attendance).insert(attendanceRecord);

  Future<bool> updateAttendanceData(AttendanceData attendanceRecord) =>
      update(attendance).replace(attendanceRecord);

  Future<int> deleteAttendance(String id) =>
      (delete(attendance)..where((a) => a.id.equals(id))).go();

  // Reminder DAO
  Future<List<Reminder>> getActiveReminders() =>
      (select(reminders)..where((r) => r.enabled.equals(true))).get();

  Future<List<Reminder>> getRemindersForCourse(String courseId) =>
      (select(reminders)..where((r) => r.courseId.equals(courseId))).get();

  Future<int> insertReminder(RemindersCompanion reminder) =>
      into(reminders).insert(reminder);

  Future<bool> updateReminder(Reminder reminder) =>
      update(reminders).replace(reminder);

  Future<int> deleteReminder(String id) =>
      (delete(reminders)..where((r) => r.id.equals(id))).go();

  // Settings DAO
  Future<String?> getSetting(String key) async {
    final result = await (select(
      settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion(key: Value(key), value: Value(value)),
    );
  }

  Future<int> deleteSetting(String key) =>
      (delete(settings)..where((s) => s.key.equals(key))).go();

  // Sync Queue DAO
  Future<List<SyncQueueData>> getPendingSyncItems() => (select(
    syncQueue,
  )..orderBy([(sq) => OrderingTerm.asc(sq.createdAt)])).get();

  Future<int> addToSyncQueue(SyncQueueCompanion item) =>
      into(syncQueue).insert(item);

  Future<int> removeSyncItem(int id) =>
      (delete(syncQueue)..where((sq) => sq.id.equals(id))).go();

  // Statistics and Complex Queries
  Future<Map<String, dynamic>> getCourseSummary(String courseId) async {
    final course = await getCourseById(courseId);
    if (course == null) return {};

    final allSessions = await getSessionsForCourse(courseId);
    final attendanceRecords = await getAttendanceForCourse(courseId);

    final totalSessions = allSessions.length;
    final attendedSessions = attendanceRecords
        .where((a) => a.status == AttendanceStatus.present)
        .length;
    final absentSessions = attendanceRecords
        .where((a) => a.status == AttendanceStatus.absent)
        .length;
    final excusedSessions = attendanceRecords
        .where((a) => a.status == AttendanceStatus.excused)
        .length;

    final attendanceRate = totalSessions > 0
        ? attendedSessions / totalSessions
        : 0.0;
    final absenceRate = totalSessions > 0
        ? absentSessions / totalSessions
        : 0.0;

    return {
      'course': course,
      'totalSessions': totalSessions,
      'attendedSessions': attendedSessions,
      'absentSessions': absentSessions,
      'excusedSessions': excusedSessions,
      'attendanceRate': attendanceRate,
      'absenceRate': absenceRate,
      'isAtRisk': absentSessions >= course.maxAbsences,
      'remainingAbsences': (course.maxAbsences - absentSessions).clamp(
        0,
        course.maxAbsences,
      ),
    };
  }

  Future<List<Map<String, dynamic>>> getAllCoursesSummary() async {
    final allCourses = await getAllCourses();
    final summaries = <Map<String, dynamic>>[];

    for (final course in allCourses) {
      final summary = await getCourseSummary(course.id);
      summaries.add(summary);
    }

    return summaries;
  }

  Future<List<Session>> getSessionsInDateRange(DateTime start, DateTime end) {
    final startMillis = start.millisecondsSinceEpoch;
    final endMillis = end.millisecondsSinceEpoch;

    return (select(sessions)
          ..where((s) => s.startUtc.isBetweenValues(startMillis, endMillis))
          ..orderBy([(s) => OrderingTerm.asc(s.startUtc)]))
        .get();
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
