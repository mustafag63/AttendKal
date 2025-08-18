import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../data/local/db.dart';
import '../data/remote/attendance_api_service.dart';
import '../providers/auth_providers.dart';
import '../providers/courses_providers.dart';
import '../providers/progress_providers.dart';

// Bugünkü oturumlar provider'ı
final todaySessionsProvider = FutureProvider<List<SessionWithAttendance>>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  // Bugünkü tüm oturumları al
  final sessions = await db.getSessionsInDateRange(startOfDay, endOfDay);

  // Her oturum için attendance bilgisini al
  final sessionWithAttendance = <SessionWithAttendance>[];
  for (final session in sessions) {
    final attendance = await db.getAttendanceForSession(session.id);
    final course = await db.getCourseById(session.courseId);

    sessionWithAttendance.add(
      SessionWithAttendance(
        session: session,
        attendance: attendance,
        course: course,
      ),
    );
  }

  // Başlama saatine göre sırala
  sessionWithAttendance.sort(
    (a, b) => a.session.startUtc.compareTo(b.session.startUtc),
  );

  return sessionWithAttendance;
});

// Kalan devamsızlık hakları provider'ı
final remainingAbsencesProvider = FutureProvider.family<int, String>((
  ref,
  courseId,
) async {
  final db = ref.watch(databaseProvider);
  final summary = await db.getCourseSummary(courseId);
  return summary['remainingAbsences'] ?? 0;
});

// Son uyarı durumu için provider
final lastStrikeWarningProvider = StateProvider<Set<String>>((ref) => {});

// Undo işlemi için provider
final undoActionProvider = StateProvider<UndoAction?>((ref) => null);

// Çakışan oturum kontrolü provider'ı
final conflictingSessionsProvider =
    FutureProvider.family<List<SessionData>, AttendanceMarkRequest>((
      ref,
      request,
    ) async {
      final db = ref.watch(databaseProvider);

      // Eğer "Katıldım" işaretlenmiyorsa çakışma kontrolü yapmaya gerek yok
      if (request.status != AttendanceStatus.present) {
        return [];
      }

      final targetSession = await db.getSessionById(request.sessionId);
      if (targetSession == null) return [];

      // Aynı zaman dilimindeki diğer "Katıldım" işaretli oturumları bul
      final sessionStart = targetSession.startUtc;
      const tolerance = 30 * 60 * 1000; // 30 dakika tolerans

      final potentiallyConflicting = await db.getSessionsInDateRange(
        DateTime.fromMillisecondsSinceEpoch(sessionStart - tolerance),
        DateTime.fromMillisecondsSinceEpoch(sessionStart + tolerance),
      );

      final conflicting = <SessionData>[];
      for (final session in potentiallyConflicting) {
        if (session.id == request.sessionId) continue;

        final attendance = await db.getAttendanceForSession(session.id);
        if (attendance?.status == AttendanceStatus.present) {
          final course = await db.getCourseById(session.courseId);
          conflicting.add(
            SessionData(
              session: session,
              course: course,
              attendance: attendance,
            ),
          );
        }
      }

      return conflicting;
    });

// Attendance işaretleme notifier'ı
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AppDatabase _db;
  final Ref _ref;
  final AttendanceApiService _apiService;

  AttendanceNotifier(this._db, this._ref, this._apiService)
    : super(const AttendanceInitialState());

  Future<void> markAttendance({
    required String sessionId,
    required AttendanceStatus status,
    String? note,
    bool skipConflictCheck = false,
  }) async {
    state = const AttendanceLoadingState();

    try {
      // Çakışma kontrolü (sadece "Katıldım" için)
      if (status == AttendanceStatus.present && !skipConflictCheck) {
        final conflicts = await _ref.read(
          conflictingSessionsProvider(
            AttendanceMarkRequest(sessionId: sessionId, status: status),
          ).future,
        );

        if (conflicts.isNotEmpty) {
          state = AttendanceConflictDetectedState(conflicts);
          return;
        }
      }

      // 48 saat kontrol
      final session = await _db.getSessionById(sessionId);
      if (session != null) {
        final sessionTime = DateTime.fromMillisecondsSinceEpoch(
          session.startUtc,
        );
        final now = DateTime.now();
        final timeDiff = now.difference(sessionTime);

        if (timeDiff.inHours > 48) {
          state = const AttendanceErrorState(
            '48 saat geçmiş oturumlar düzenlenemez',
          );
          return;
        }
      }

      // Mevcut attendance'ı kontrol et
      final existingAttendance = await _db.getAttendanceForSession(sessionId);
      final previousStatus = existingAttendance?.status;

      final now = DateTime.now().millisecondsSinceEpoch;

      if (existingAttendance != null) {
        // Güncelle - AttendanceData nesnesini yeniden oluştur
        final updatedAttendance = AttendanceData(
          id: existingAttendance.id,
          sessionId: existingAttendance.sessionId,
          userId: existingAttendance.userId,
          status: status,
          note: note,
          markedAt: existingAttendance.markedAt,
          timestamp: now,
          latitude: existingAttendance.latitude,
          longitude: existingAttendance.longitude,
          createdAt: existingAttendance.createdAt,
          updatedAt: now,
        );
        await _db.updateAttendanceData(updatedAttendance);
      } else {
        // Yeni kayıt
        final attendanceId = const Uuid().v4();
        await _db.insertAttendance(
          AttendanceCompanion.insert(
            id: attendanceId,
            sessionId: sessionId,
            userId: 'current_user', // TODO: Actual user ID
            status: status,
            timestamp: now,
            markedAt: now,
            note: Value(note),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      // Backend'e senkronize et
      try {
        await _apiService.markAttendance(
          sessionId: sessionId,
          status: status,
          note: note,
        );
      } catch (e) {
        // Backend hatası varsa log et ama yerel işlemi engelleme
        debugPrint('Backend sync failed: $e');
        // TODO: Add to sync queue for later retry
      }

      // Undo action'ı kaydet
      _ref.read(undoActionProvider.notifier).state = UndoAction(
        sessionId: sessionId,
        previousStatus: previousStatus,
        currentStatus: status,
        timestamp: DateTime.now(),
      );

      // Son uyarı kontrolü (yalnızca "Kaçırdım" işaretlendiğinde)
      if (status == AttendanceStatus.absent && session != null) {
        final remaining = await _ref.read(
          remainingAbsencesProvider(session.courseId).future,
        );
        if (remaining == 1) {
          final lastStrikeSet = _ref.read(lastStrikeWarningProvider);
          if (!lastStrikeSet.contains(session.courseId)) {
            _ref.read(lastStrikeWarningProvider.notifier).state = {
              ...lastStrikeSet,
              session.courseId,
            };
            state = AttendanceLastStrikeWarningState(session.courseId);
            return;
          }
        }
      }

      // Providers'ı invalidate et
      _ref.invalidate(todaySessionsProvider);
      _ref.invalidate(remainingAbsencesProvider(session?.courseId ?? ''));

      // Progress providers'ını da refresh et
      refreshProgressData(_ref);

      state = const AttendanceSuccessState();
    } catch (error) {
      state = AttendanceErrorState(error.toString());
    }
  }

  Future<void> confirmConflictingAttendance({
    required String sessionId,
    required AttendanceStatus status,
    String? note,
  }) async {
    await markAttendance(
      sessionId: sessionId,
      status: status,
      note: note,
      skipConflictCheck: true,
    );
  }

  Future<void> undoLastAction() async {
    final undoAction = _ref.read(undoActionProvider);
    if (undoAction == null) return;

    final timeDiff = DateTime.now().difference(undoAction.timestamp);
    if (timeDiff.inMinutes > 10) {
      _ref.read(undoActionProvider.notifier).state = null;
      return; // 10 dakika geçmiş
    }

    try {
      if (undoAction.previousStatus != null) {
        // Eski duruma geri döndür
        await markAttendance(
          sessionId: undoAction.sessionId,
          status: undoAction.previousStatus!,
          skipConflictCheck: true,
        );
      } else {
        // Kaydı sil
        final attendance = await _db.getAttendanceForSession(
          undoAction.sessionId,
        );
        if (attendance != null) {
          await _db.deleteAttendance(attendance.id);
        }
      }

      _ref.read(undoActionProvider.notifier).state = null;
      _ref.invalidate(todaySessionsProvider);
    } catch (error) {
      state = AttendanceErrorState('Geri alma işlemi başarısız: $error');
    }
  }

  void clearUndoAction() {
    _ref.read(undoActionProvider.notifier).state = null;
  }

  void dismissLastStrikeWarning(String courseId) {
    final currentSet = _ref.read(lastStrikeWarningProvider);
    _ref.read(lastStrikeWarningProvider.notifier).state = currentSet
        .where((id) => id != courseId)
        .toSet();
  }
}

// API Service provider
final attendanceApiServiceProvider = Provider<AttendanceApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AttendanceApiService(dioClient);
});

final attendanceNotifierProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
      final db = ref.watch(databaseProvider);
      final apiService = ref.watch(attendanceApiServiceProvider);
      return AttendanceNotifier(db, ref, apiService);
    });

// Data classes
class SessionWithAttendance {
  final Session session;
  final AttendanceData? attendance;
  final Course? course;

  SessionWithAttendance({required this.session, this.attendance, this.course});
}

class SessionData {
  final Session session;
  final Course? course;
  final AttendanceData? attendance;

  SessionData({required this.session, this.course, this.attendance});
}

class AttendanceMarkRequest {
  final String sessionId;
  final AttendanceStatus status;

  AttendanceMarkRequest({required this.sessionId, required this.status});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceMarkRequest &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          status == other.status;

  @override
  int get hashCode => sessionId.hashCode ^ status.hashCode;
}

class UndoAction {
  final String sessionId;
  final AttendanceStatus? previousStatus;
  final AttendanceStatus currentStatus;
  final DateTime timestamp;

  UndoAction({
    required this.sessionId,
    this.previousStatus,
    required this.currentStatus,
    required this.timestamp,
  });
}

// State classes
sealed class AttendanceState {
  const AttendanceState();
}

final class AttendanceInitialState extends AttendanceState {
  const AttendanceInitialState();
}

final class AttendanceLoadingState extends AttendanceState {
  const AttendanceLoadingState();
}

final class AttendanceSuccessState extends AttendanceState {
  const AttendanceSuccessState();
}

final class AttendanceErrorState extends AttendanceState {
  final String message;
  const AttendanceErrorState(this.message);
}

final class AttendanceConflictDetectedState extends AttendanceState {
  final List<SessionData> conflicts;
  const AttendanceConflictDetectedState(this.conflicts);
}

final class AttendanceLastStrikeWarningState extends AttendanceState {
  final String courseId;
  const AttendanceLastStrikeWarningState(this.courseId);
}
