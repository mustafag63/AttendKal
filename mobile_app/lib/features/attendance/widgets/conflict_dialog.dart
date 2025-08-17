import 'package:flutter/material.dart';
import '../../../providers/attendance_providers.dart';
import '../../../data/local/database.dart';

class ConflictDialog extends StatelessWidget {
  final List<SessionData> conflicts;
  final Function(String sessionId, AttendanceStatus status, String? note)
  onConfirm;
  final VoidCallback onCancel;

  const ConflictDialog({
    super.key,
    required this.conflicts,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 24),
          const SizedBox(width: 8),
          const Text('Çakışan Oturum'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aynı saatte başka bir derse "Katıldım" olarak işaretlediniz. Bu normal mi?',
          ),
          const SizedBox(height: 16),
          const Text(
            'Çakışan dersler:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...conflicts.map(
            (sessionData) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sessionData.course?.name ?? 'Bilinmeyen Ders',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    _formatTime(sessionData.session.startUtc),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel();
          },
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Note: The actual session ID and status should be passed from parent context
            // This is a simplified version - in a real implementation, you'd need to pass
            // the original marking request data to this dialog
          },
          child: const Text('Devam Et'),
        ),
      ],
    );
  }

  String _formatTime(int timestamp) {
    final time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
