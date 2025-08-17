import 'package:drift/drift.dart';
import 'db.dart';

// Migration examples and utilities
class DatabaseMigrations {
  // Example migration from version 1 to 2
  static Future<void> migrateV1ToV2(Migrator m, AppDatabase db) async {
    // Example: Add new column to courses table
    // await m.addColumn(db.courses, db.courses.newColumn);

    // Example: Create new table
    // await m.createTable(db.newTable);

    // Example: Populate data
    // await db.into(db.settings).insert(
    //   SettingsCompanion.insert(
    //     key: 'app_version',
    //     value: '2.0.0',
    //   ),
    // );
  }

  // Example migration from version 2 to 3
  static Future<void> migrateV2ToV3(Migrator m, AppDatabase db) async {
    // Example: Drop and recreate index
    // await db.customStatement('DROP INDEX IF EXISTS idx_old_name');
    // await db.customStatement('''
    //   CREATE INDEX idx_new_name
    //   ON table_name(column1, column2);
    // ''');
  }
}

// Database initialization helper
class DatabaseInitializer {
  static Future<void> initializeDefaultData(AppDatabase db) async {
    // Insert default settings
    await db.setSetting('app_version', '1.0.0');
    await db.setSetting('theme_mode', 'system');
    await db.setSetting('notification_enabled', 'true');
    await db.setSetting('sync_enabled', 'false');

    // Insert default course colors (as indices to AppColors.courseColors)
    await db.setSetting(
      'default_course_colors',
      '[0,1,2,3,4,5,6,7]',
    ); // JSON array of color indices
  }

  static Future<void> seedSampleData(AppDatabase db) async {
    // Sample course
    final courseId = 'course_1';
    await db
        .into(db.courses)
        .insert(
          CoursesCompanion.insert(
            id: courseId,
            name: 'Flutter Development',
            code: 'CS301',
            teacher: 'Dr. Smith',
            location: 'Room 101',
            color: 0x6B73FF, // AppColors.courseColors[0].value
            note: 'Mobile app development with Flutter',
            maxAbsences: 3,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    // Sample meeting
    await db
        .into(db.meetings)
        .insert(
          MeetingsCompanion.insert(
            id: 'meeting_1',
            courseId: courseId,
            weekday: 1, // Monday
            startHHmm: '09:00',
            durationMin: 90,
            location: 'Room 101',
            note: 'Weekly lecture',
          ),
        );

    // Sample reminder
    await db
        .into(db.reminders)
        .insert(
          RemindersCompanion.insert(
            id: 'reminder_1',
            userId: 'user_1',
            courseId: Value(courseId),
            title: 'Flutter Class Tomorrow',
            morningOfClass: true,
            minutesBefore: 60,
            thresholdAlerts: false,
            enabled: true,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }
}

// Utility functions for common database operations
extension DatabaseUtils on AppDatabase {
  Future<bool> courseExists(String courseId) async {
    final course = await getCourseById(courseId);
    return course != null;
  }

  Future<bool> sessionExists(String sessionId) async {
    final query = select(sessions)..where((s) => s.id.equals(sessionId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  Future<int> getTotalCoursesCount() async {
    final countQuery = selectOnly(courses)..addColumns([courses.id.count()]);
    final result = await countQuery.getSingle();
    return result.read(courses.id.count()) ?? 0;
  }

  Future<int> getTotalSessionsCount() async {
    final countQuery = selectOnly(sessions)..addColumns([sessions.id.count()]);
    final result = await countQuery.getSingle();
    return result.read(sessions.id.count()) ?? 0;
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(syncQueue).go();
      await delete(attendance).go();
      await delete(sessions).go();
      await delete(meetings).go();
      await delete(reminders).go();
      await delete(courses).go();
      // Keep settings
    });
  }

  Future<void> exportUserData() async {
    // This would be implemented to export user data as JSON
    // for backup/restore functionality
  }

  Future<void> importUserData(Map<String, dynamic> data) async {
    // This would be implemented to import user data from JSON
    // for backup/restore functionality
  }
}

// Course-specific utilities
extension CourseUtils on AppDatabase {
  Future<double> calculateAttendancePercentage(String courseId) async {
    final summary = await getCourseSummary(courseId);
    return (summary['attendanceRate'] as double? ?? 0.0) * 100;
  }

  Future<List<String>> getCoursesAtRisk() async {
    final summaries = await getAllCoursesSummary();
    return summaries
        .where((s) => s['isAtRisk'] == true)
        .map((s) => (s['course'] as Course).id)
        .toList();
  }

  Future<Map<String, int>> getWeeklyAttendanceStats(String courseId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final sessionsThisWeek = await getSessionsInDateRange(
      startOfWeek,
      endOfWeek,
    );
    final courseSessionsThisWeek = sessionsThisWeek
        .where((s) => s.courseId == courseId)
        .toList();

    int attended = 0;
    int total = courseSessionsThisWeek.length;

    for (final session in courseSessionsThisWeek) {
      final attendanceRecord = await getAttendanceForSession(session.id);
      if (attendanceRecord?.status == AttendanceStatus.present) {
        attended++;
      }
    }

    return {'attended': attended, 'total': total, 'absent': total - attended};
  }
}
