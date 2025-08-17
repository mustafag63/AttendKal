import 'package:flutter/material.dart';
import '../../../data/local/db.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheduledTime = DateTime.fromMillisecondsSinceEpoch(
      reminder.scheduledTime,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          reminder.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: reminder.isActive
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface.withOpacity(0.6),
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Time
                        Text(
                          _formatTime(scheduledTime),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(reminder.type).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getTypeText(reminder.type),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getTypeColor(reminder.type),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Active toggle
                  Switch(
                    value: reminder.isActive,
                    onChanged: onToggle,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),

              if (reminder.description != null &&
                  reminder.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  reminder.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              if (reminder.courseId != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.school, size: 16, color: colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      'Ders hatırlatıcısı',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // Repeat info
              if (reminder.repeatType != RepeatType.once) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.repeat, size: 16, color: colorScheme.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      _getRepeatText(reminder.repeatType),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Düzenle'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(width: 8),

                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Sil'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = time.difference(now);

    if (diff.inDays > 0) {
      return '${diff.inDays} gün sonra • ${_formatHour(time)}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} saat sonra • ${_formatHour(time)}';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} dakika sonra';
    } else if (diff.inMinutes < 0 && diff.inDays == 0) {
      return 'Bugün • ${_formatHour(time)}';
    } else {
      return '${(-diff.inDays)} gün önce • ${_formatHour(time)}';
    }
  }

  String _formatHour(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.courseMorning:
        return Colors.blue;
      case ReminderType.coursePreStart:
        return Colors.orange;
      case ReminderType.custom:
        return Colors.purple;
    }
  }

  String _getTypeText(ReminderType type) {
    switch (type) {
      case ReminderType.courseMorning:
        return 'Sabah';
      case ReminderType.coursePreStart:
        return 'Ders Öncesi';
      case ReminderType.custom:
        return 'Özel';
    }
  }

  String _getRepeatText(RepeatType type) {
    switch (type) {
      case RepeatType.once:
        return '';
      case RepeatType.daily:
        return 'Her gün';
      case RepeatType.weekly:
        return 'Her hafta';
      case RepeatType.monthly:
        return 'Her ay';
    }
  }
}
