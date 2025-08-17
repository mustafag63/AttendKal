import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/attendance_providers.dart';
import '../../data/local/db.dart';
import 'widgets/session_card.dart';
import 'widgets/undo_snackbar.dart';
import 'widgets/conflict_dialog.dart';
import 'widgets/last_strike_dialog.dart';

class TodayAttendanceScreen extends ConsumerStatefulWidget {
  const TodayAttendanceScreen({super.key});

  @override
  ConsumerState<TodayAttendanceScreen> createState() =>
      _TodayAttendanceScreenState();
}

class _TodayAttendanceScreenState extends ConsumerState<TodayAttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(todaySessionsProvider);
    final attendanceState = ref.watch(attendanceNotifierProvider);
    final undoAction = ref.watch(undoActionProvider);

    // State listener for dialogs and snackbars
    ref.listen<AttendanceState>(attendanceNotifierProvider, (previous, next) {
      if (next is AttendanceConflictDetectedState) {
        _showConflictDialog(context, next.conflicts);
      } else if (next is AttendanceLastStrikeWarningState) {
        _showLastStrikeDialog(context, next.courseId);
      } else if (next is AttendanceErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      } else if (next is AttendanceSuccessState) {
        if (undoAction != null) {
          _showUndoSnackbar(context, undoAction);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugün'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (undoAction != null)
            TextButton.icon(
              onPressed: () {
                ref.read(attendanceNotifierProvider.notifier).undoLastAction();
              },
              icon: const Icon(Icons.undo),
              label: const Text('Geri Al'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todaySessionsProvider);
        },
        child: sessionsAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final sessionWithAttendance = sessions[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SessionCard(
                    session: sessionWithAttendance.session,
                    course: sessionWithAttendance.course,
                    attendance: sessionWithAttendance.attendance,
                    onMarkAttendance: (status, note) => _markAttendance(
                      sessionWithAttendance.session.id,
                      status,
                      note,
                    ),
                    isLoading: attendanceState is AttendanceLoadingState,
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Oturumlar yüklenirken hata oluştu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(todaySessionsProvider),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.today, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Bugün ders yok',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Bugün için planlanmış ders bulunmuyor',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _markAttendance(
    String sessionId,
    AttendanceStatus status,
    String? note,
  ) {
    ref
        .read(attendanceNotifierProvider.notifier)
        .markAttendance(sessionId: sessionId, status: status, note: note);
  }

  void _showConflictDialog(BuildContext context, List<SessionData> conflicts) {
    showDialog(
      context: context,
      builder: (context) => ConflictDialog(
        conflicts: conflicts,
        onConfirm: (sessionId, status, note) {
          ref
              .read(attendanceNotifierProvider.notifier)
              .confirmConflictingAttendance(
                sessionId: sessionId,
                status: status,
                note: note,
              );
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showLastStrikeDialog(BuildContext context, String courseId) {
    showDialog(
      context: context,
      builder: (context) => LastStrikeDialog(
        courseId: courseId,
        onDismiss: () {
          ref
              .read(attendanceNotifierProvider.notifier)
              .dismissLastStrikeWarning(courseId);
        },
      ),
    );
  }

  void _showUndoSnackbar(BuildContext context, UndoAction undoAction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: UndoSnackbar(
          undoAction: undoAction,
          onUndo: () {
            ref.read(attendanceNotifierProvider.notifier).undoLastAction();
          },
          onDismiss: () {
            ref.read(attendanceNotifierProvider.notifier).clearUndoAction();
          },
        ),
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
