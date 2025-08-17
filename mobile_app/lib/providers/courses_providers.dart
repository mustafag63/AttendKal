import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../data/local/db.dart';

class CoursesSummary {
  final int totalCourses;
  final int totalMeetings;
  final int totalAttendances;
  final double attendanceRate;

  CoursesSummary({
    required this.totalCourses,
    required this.totalMeetings,
    required this.totalAttendances,
    required this.attendanceRate,
  });
}

// UUID generator
const _uuid = Uuid();

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

// Courses provider
final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getAllCourses();
});

// Course detail provider
final courseDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, courseId) async {
      final db = ref.watch(databaseProvider);
      return await db.getCourseSummary(courseId);
    });

// Meetings provider for course
final courseMeetingsProvider = FutureProvider.family<List<Meeting>, String>((
  ref,
  courseId,
) async {
  final db = ref.watch(databaseProvider);
  return await db.getMeetingsForCourse(courseId);
});

// Course sessions provider
final courseSessionsProvider = FutureProvider.family<List<Session>, String>((
  ref,
  courseId,
) async {
  final db = ref.watch(databaseProvider);
  return await db.getSessionsForCourse(courseId);
});

// Course notifier for state management
class CourseNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  final AppDatabase _db;
  final Ref _ref;

  CourseNotifier(this._db, this._ref) : super(const AsyncValue.loading()) {
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await _db.getAllCourses();
      state = AsyncValue.data(courses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Course> addCourse({
    required String name,
    required String code,
    String? teacher,
    String? location,
    required Color color,
    String? note,
    required int maxAbsences,
  }) async {
    try {
      final courseId = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      final course = CoursesCompanion.insert(
        id: courseId,
        name: name,
        code: code,
        teacher: teacher != null ? Value(teacher) : const Value.absent(),
        location: location != null ? Value(location) : const Value.absent(),
        color: color,
        note: note != null ? Value(note) : const Value.absent(),
        maxAbsences: maxAbsences,
        createdAt: now,
        updatedAt: now,
      );

      await _db.insertCourse(course);

      // Add to sync queue for backend sync
      await _db.addToSyncQueue('insert', 'courses', courseId, {
        'id': courseId,
        'name': name,
        'code': code,
        'teacher': teacher,
        'location': location,
        'color': color.value,
        'note': note,
        'maxAbsences': maxAbsences,
        'createdAt': now,
        'updatedAt': now,
      });

      // Invalidate providers to refresh UI
      _ref.invalidate(coursesProvider);
      _ref.invalidate(coursesSummaryProvider);

      // Optimistically update state
      _loadCourses();

      // Return the created course
      final createdCourse = await _db.getCourseById(courseId);
      return createdCourse!;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCourse({
    required String courseId,
    required String name,
    required String code,
    String? teacher,
    String? location,
    required Color color,
    String? note,
    required int maxAbsences,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      final course = CoursesCompanion(
        id: Value(courseId),
        name: Value(name),
        code: Value(code),
        teacher: teacher != null ? Value(teacher) : const Value.absent(),
        location: location != null ? Value(location) : const Value.absent(),
        color: Value(color),
        note: note != null ? Value(note) : const Value.absent(),
        maxAbsences: Value(maxAbsences),
        updatedAt: Value(now),
      );

      await _db.updateCourse(course);

      // Add to sync queue
      await _db.addToSyncQueue('update', 'courses', courseId, {
        'id': courseId,
        'name': name,
        'code': code,
        'teacher': teacher,
        'location': location,
        'color': color.value,
        'note': note,
        'maxAbsences': maxAbsences,
        'updatedAt': now,
      });

      // Invalidate providers
      _ref.invalidate(coursesProvider);
      _ref.invalidate(coursesSummaryProvider);
      _ref.invalidate(courseDetailProvider(courseId));

      _loadCourses();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _db.deleteCourse(courseId);

      // Add to sync queue
      await _db.addToSyncQueue('delete', 'courses', courseId, {'id': courseId});

      // Invalidate providers
      _ref.invalidate(coursesProvider);
      _ref.invalidate(coursesSummaryProvider);
      _ref.invalidate(courseDetailProvider(courseId));

      _loadCourses();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadCourses();
  }
}

// Course notifier provider
final courseNotifierProvider =
    StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>((ref) {
      final db = ref.watch(databaseProvider);
      return CourseNotifier(db, ref);
    });

// Meeting notifier for managing course meetings
class MeetingNotifier extends StateNotifier<AsyncValue<List<Meeting>>> {
  final AppDatabase _db;
  final Ref _ref;
  final String courseId;

  MeetingNotifier(this._db, this._ref, this.courseId)
    : super(const AsyncValue.loading()) {
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    try {
      final meetings = await _db.getMeetingsForCourse(courseId);
      state = AsyncValue.data(meetings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addMeeting({
    required int weekday,
    required String startHHmm,
    required int durationMin,
    String? location,
    String? note,
  }) async {
    try {
      final meetingId = _uuid.v4();

      final meeting = MeetingsCompanion.insert(
        id: meetingId,
        courseId: courseId,
        weekday: weekday,
        startHHmm: startHHmm,
        durationMin: durationMin,
        location: location != null ? Value(location) : const Value.absent(),
        note: note != null ? Value(note) : const Value.absent(),
      );

      await _db.insertMeeting(meeting);

      // Add to sync queue
      await _db.addToSyncQueue('insert', 'meetings', meetingId, {
        'id': meetingId,
        'courseId': courseId,
        'weekday': weekday,
        'startHHmm': startHHmm,
        'durationMin': durationMin,
        'location': location,
        'note': note,
      });

      // Invalidate providers
      _ref.invalidate(courseMeetingsProvider(courseId));

      _loadMeetings();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteMeeting(String meetingId) async {
    try {
      await _db.deleteMeeting(meetingId);

      // Add to sync queue
      await _db.addToSyncQueue('delete', 'meetings', meetingId, {
        'id': meetingId,
      });

      // Invalidate providers
      _ref.invalidate(courseMeetingsProvider(courseId));

      _loadMeetings();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Meeting notifier provider factory
final meetingNotifierProvider =
    StateNotifierProvider.family<
      MeetingNotifier,
      AsyncValue<List<Meeting>>,
      String
    >((ref, courseId) {
      final db = ref.watch(databaseProvider);
      return MeetingNotifier(db, ref, courseId);
    });

// Course provider
final courseProvider = FutureProvider.family<Course?, String>((
  ref,
  courseId,
) async {
  final db = ref.watch(databaseProvider);
  return await db.getCourseById(courseId);
});

// Courses summary provider
final coursesSummaryProvider = FutureProvider<CoursesSummary>((ref) async {
  final db = ref.watch(databaseProvider);

  final courses = await db.getAllCourses();
  final meetings = await db.getAllMeetings();
  final attendances = await db.getAllAttendances();

  final totalCourses = courses.length;
  final totalMeetings = meetings.length;
  final totalAttendances = attendances
      .where((a) => a.status == AttendanceStatus.present)
      .length;

  final attendanceRate = totalMeetings > 0
      ? (totalAttendances / totalMeetings) * 100
      : 0.0;

  return CoursesSummary(
    totalCourses: totalCourses,
    totalMeetings: totalMeetings,
    totalAttendances: totalAttendances,
    attendanceRate: attendanceRate,
  );
});
