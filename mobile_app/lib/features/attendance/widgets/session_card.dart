import 'package:flutter/material.dart';
import '../../../data/local/database.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  final Course? course;
  final AttendanceData? attendance;
  final Function(AttendanceStatus status, String? note) onMarkAttendance;
  final bool isLoading;

  const SessionCard({
    super.key,
    required this.session,
    this.course,
    this.attendance,
    required this.onMarkAttendance,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final sessionTime = DateTime.fromMillisecondsSinceEpoch(session.startUtc);
    final now = DateTime.now();
    final isInPast = sessionTime.isBefore(now);
    final timeDiff = sessionTime.difference(now);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with course name and time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course?.name ?? 'Bilinmeyen Ders',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(sessionTime),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Time status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTimeStatusColor(timeDiff).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getTimeStatusText(timeDiff, isInPast),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getTimeStatusColor(timeDiff),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Current attendance status (if any)
            if (attendance != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getAttendanceColor(
                    attendance!.status,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getAttendanceColor(
                      attendance!.status,
                    ).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getAttendanceIcon(attendance!.status),
                      color: _getAttendanceColor(attendance!.status),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Durum: ${_getAttendanceText(attendance!.status)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getAttendanceColor(attendance!.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            if (_canMarkAttendance(sessionTime))
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: 'Katıldım',
                      icon: Icons.check_circle,
                      color: Colors.green,
                      status: AttendanceStatus.present,
                      isSelected:
                          attendance?.status == AttendanceStatus.present,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: 'Kaçırdım',
                      icon: Icons.cancel,
                      color: Colors.red,
                      status: AttendanceStatus.absent,
                      isSelected: attendance?.status == AttendanceStatus.absent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      label: 'Mazeretli',
                      icon: Icons.info,
                      color: Colors.orange,
                      status: AttendanceStatus.excused,
                      isSelected:
                          attendance?.status == AttendanceStatus.excused,
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '48 saat geçmiş - düzenlenemez',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required AttendanceStatus status,
    required bool isSelected,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : () => onMarkAttendance(status, null),
      icon: isLoading && isSelected
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey[100],
        foregroundColor: isSelected ? Colors.white : Colors.grey[700],
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  bool _canMarkAttendance(DateTime sessionTime) {
    final now = DateTime.now();
    final timeDiff = now.difference(sessionTime);
    return timeDiff.inHours <= 48; // 48 saat içinde düzenlenebilir
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _getTimeStatusColor(Duration timeDiff) {
    if (timeDiff.isNegative) {
      if (timeDiff.inMinutes > -30) {
        return Colors.green; // Yakında başlayacak
      } else {
        return Colors.blue; // İleri tarih
      }
    } else {
      if (timeDiff.inHours < 2) {
        return Colors.orange; // Yakın zamanda bitti
      } else {
        return Colors.grey; // Geçmiş
      }
    }
  }

  String _getTimeStatusText(Duration timeDiff, bool isInPast) {
    if (timeDiff.isNegative) {
      final absDiff = timeDiff.abs();
      if (absDiff.inMinutes < 30) {
        return 'Yakında';
      } else if (absDiff.inHours < 24) {
        return '${absDiff.inHours}s sonra';
      } else {
        return '${absDiff.inDays}g sonra';
      }
    } else {
      if (timeDiff.inHours < 24) {
        return '${timeDiff.inHours}s önce';
      } else {
        return '${timeDiff.inDays}g önce';
      }
    }
  }

  Color _getAttendanceColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }

  IconData _getAttendanceIcon(AttendanceStatus status) {
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

  String _getAttendanceText(AttendanceStatus status) {
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
