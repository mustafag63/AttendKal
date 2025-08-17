import 'package:flutter/material.dart';
import '../../../providers/attendance_providers.dart';
import '../../../data/local/database.dart';

class UndoSnackbar extends StatelessWidget {
  final UndoAction undoAction;
  final VoidCallback onUndo;
  final VoidCallback onDismiss;

  const UndoSnackbar({
    super.key,
    required this.undoAction,
    required this.onUndo,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(undoAction.currentStatus),
            color: Theme.of(context).colorScheme.onInverseSurface,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getUndoMessage(undoAction),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: onUndo,
            child: Text(
              'GERİ AL',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _getUndoMessage(UndoAction action) {
    final currentStatusText = _getStatusText(action.currentStatus);
    return 'Devamsızlık "$currentStatusText" olarak işaretlendi';
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.access_time;
      case AttendanceStatus.excused:
        return Icons.info;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Katıldım';
      case AttendanceStatus.absent:
        return 'Kaçırdım';
      case AttendanceStatus.late:
        return 'Geç Kaldım';
      case AttendanceStatus.excused:
        return 'Mazeretli';
    }
  }
}
