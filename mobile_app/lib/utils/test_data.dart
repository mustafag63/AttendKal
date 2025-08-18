// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../data/local/db.dart';
import '../providers/courses_providers.dart';

// Test data provider for development
final testDataProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(databaseProvider);

  // Mock course data
  final courseId1 = 'course_1';
  final courseId2 = 'course_2';

  // Add test courses
  try {
    await db.insertCourse(
      CoursesCompanion.insert(
        id: courseId1,
        name: 'Algoritma ve Programlama',
        code: 'CS101',
        color: const Color(0xFF2196F3), // Blue
        maxAbsences: 3,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    await db.insertCourse(
      CoursesCompanion.insert(
        id: courseId2,
        name: 'Veritabanı Sistemleri',
        code: 'CS201',
        color: const Color(0xFF4CAF50), // Green
        maxAbsences: 4,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    // Add test sessions for today
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // Session 1: 09:00 today
    final session1Time = todayStart.add(const Duration(hours: 9));
    await db.insertSession(
      SessionsCompanion.insert(
        id: 'session_1',
        courseId: courseId1,
        startUtc: session1Time.millisecondsSinceEpoch,
        endUtc: Value(
          session1Time.add(const Duration(hours: 2)).millisecondsSinceEpoch,
        ),
        durationMin: 120,
        source: 'test',
        note: const Value('Haftalık ders'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    // Session 2: 14:00 today
    final session2Time = todayStart.add(const Duration(hours: 14));
    await db.insertSession(
      SessionsCompanion.insert(
        id: 'session_2',
        courseId: courseId2,
        startUtc: session2Time.millisecondsSinceEpoch,
        endUtc: Value(
          session2Time.add(const Duration(hours: 3)).millisecondsSinceEpoch,
        ),
        durationMin: 180,
        source: 'test',
        note: const Value('Lab çalışması'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    // Session 3: 18:00 today (for conflict testing)
    final session3Time = todayStart.add(const Duration(hours: 18));
    await db.insertSession(
      SessionsCompanion.insert(
        id: 'session_3',
        courseId: courseId1,
        startUtc: session3Time.millisecondsSinceEpoch,
        endUtc: Value(
          session3Time
              .add(const Duration(hours: 1, minutes: 30))
              .millisecondsSinceEpoch,
        ),
        durationMin: 90,
        source: 'test',
        note: const Value('Ek ders'),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    // Add historical sessions for progress tracking
    await _addHistoricalData(db, courseId1, courseId2);

    print('✅ Test data created successfully');
  } catch (e) {
    print('❌ Error creating test data: $e');
  }
});

// Add historical sessions and attendance for progress demonstration
Future<void> _addHistoricalData(
  AppDatabase db,
  String courseId1,
  String courseId2,
) async {
  final now = DateTime.now();

  // Add past sessions for the last 8 weeks
  for (int weekOffset = 1; weekOffset <= 8; weekOffset++) {
    for (int dayOffset = 0; dayOffset < 5; dayOffset++) {
      // Mon-Fri
      final sessionDate = now.subtract(
        Duration(days: (weekOffset * 7) + dayOffset),
      );

      // Course 1 sessions (Mon, Wed, Fri)
      if (dayOffset == 0 || dayOffset == 2 || dayOffset == 4) {
        final sessionId = 'hist_${courseId1}_${weekOffset}_$dayOffset';
        final sessionStart = DateTime(
          sessionDate.year,
          sessionDate.month,
          sessionDate.day,
          9, // 9 AM
        );

        await db.insertSession(
          SessionsCompanion.insert(
            id: sessionId,
            courseId: courseId1,
            startUtc: sessionStart.millisecondsSinceEpoch,
            endUtc: Value(
              sessionStart.add(const Duration(hours: 2)).millisecondsSinceEpoch,
            ),
            durationMin: 120,
            source: 'historical',
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

        // Add attendance with some randomness for realistic data
        AttendanceStatus status;
        if (weekOffset <= 2) {
          // Recent weeks - better attendance
          status = dayOffset == 4 && weekOffset == 1
              ? AttendanceStatus
                    .absent // One absence in recent history
              : AttendanceStatus.present;
        } else if (weekOffset <= 5) {
          // Middle weeks - mixed attendance
          status = (dayOffset + weekOffset) % 4 == 0
              ? AttendanceStatus.absent
              : AttendanceStatus.present;
        } else {
          // Older weeks - worse attendance initially
          status = dayOffset == 2
              ? AttendanceStatus.excused
              : (weekOffset + dayOffset) % 3 == 0
              ? AttendanceStatus.absent
              : AttendanceStatus.present;
        }

        await db.insertAttendance(
          AttendanceCompanion.insert(
            id: const Uuid().v4(),
            sessionId: sessionId,
            userId: 'test_user',
            status: status,
            timestamp: sessionStart.millisecondsSinceEpoch,
            markedAt: sessionStart.millisecondsSinceEpoch,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }

      // Course 2 sessions (Tue, Thu)
      if (dayOffset == 1 || dayOffset == 3) {
        final sessionId = 'hist_${courseId2}_${weekOffset}_$dayOffset';
        final sessionStart = DateTime(
          sessionDate.year,
          sessionDate.month,
          sessionDate.day,
          14, // 2 PM
        );

        await db.insertSession(
          SessionsCompanion.insert(
            id: sessionId,
            courseId: courseId2,
            startUtc: sessionStart.millisecondsSinceEpoch,
            endUtc: Value(
              sessionStart.add(const Duration(hours: 3)).millisecondsSinceEpoch,
            ),
            durationMin: 180,
            source: 'historical',
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

        // Add attendance for course 2
        AttendanceStatus status;
        if (weekOffset <= 3) {
          // Recent weeks - excellent attendance for this course
          status = AttendanceStatus.present;
        } else if (weekOffset <= 6) {
          // Middle weeks - good attendance with one excused
          status = weekOffset == 4 && dayOffset == 1
              ? AttendanceStatus.excused
              : AttendanceStatus.present;
        } else {
          // Older weeks - some absences
          status = weekOffset == 8 && dayOffset == 3
              ? AttendanceStatus.absent
              : AttendanceStatus.present;
        }

        await db.insertAttendance(
          AttendanceCompanion.insert(
            id: const Uuid().v4(),
            sessionId: sessionId,
            userId: 'test_user',
            status: status,
            timestamp: sessionStart.millisecondsSinceEpoch,
            markedAt: sessionStart.millisecondsSinceEpoch,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }
  }

  print('📊 Historical attendance data added for progress tracking');
}

// Helper function to reset test data
Future<void> resetTestData(WidgetRef ref) async {
  final db = ref.read(databaseProvider);

  // Clear existing data
  await db.customStatement('DELETE FROM attendance');
  await db.customStatement('DELETE FROM sessions');
  await db.customStatement('DELETE FROM meetings');
  await db.customStatement('DELETE FROM courses');

  // Recreate test data
  ref.invalidate(testDataProvider);
  await ref.read(testDataProvider.future);

  print('🔄 Test data reset successfully');
}
