import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database.dart';
import '../../../providers/reminder_providers.dart';
import '../../../providers/courses_providers.dart';

class AddReminderDialog extends ConsumerStatefulWidget {
  final Reminder? reminder; // null for add, non-null for edit

  const AddReminderDialog({super.key, this.reminder});

  @override
  ConsumerState<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends ConsumerState<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _selectedDateTime;
  ReminderType _selectedType = ReminderType.custom;
  RepeatType _selectedRepeat = RepeatType.once;
  String? _selectedCourseId;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.reminder != null) {
      // Edit mode
      final reminder = widget.reminder!;
      _titleController.text = reminder.title;
      _descriptionController.text = reminder.description ?? '';
      _selectedDateTime = DateTime.fromMillisecondsSinceEpoch(
        reminder.scheduledTime,
      );
      _selectedType = reminder.type;
      _selectedRepeat = reminder.repeatType;
      _selectedCourseId = reminder.courseId;
      _isActive = reminder.isActive;
    } else {
      // Add mode
      _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.reminder != null
                          ? 'Hatırlatıcı Düzenle'
                          : 'Yeni Hatırlatıcı',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Başlık',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Başlık gerekli';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Açıklama (Opsiyonel)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),

                      // Type selection
                      DropdownButtonFormField<ReminderType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tür',
                          border: OutlineInputBorder(),
                        ),
                        items: ReminderType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getTypeText(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedType = value;
                              if (value != ReminderType.custom) {
                                // For course-related reminders, clear course selection
                                // User will select course separately
                              }
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Course selection (only for course-related types)
                      if (_selectedType != ReminderType.custom) ...[
                        coursesAsync.when(
                          data: (courses) => DropdownButtonFormField<String>(
                            value: _selectedCourseId,
                            decoration: const InputDecoration(
                              labelText: 'Ders',
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Ders seçin'),
                            items: courses.map((course) {
                              return DropdownMenuItem(
                                value: course.id,
                                child: Text(course.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCourseId = value;
                              });
                            },
                            validator: (value) {
                              if (_selectedType != ReminderType.custom &&
                                  value == null) {
                                return 'Ders seçimi gerekli';
                              }
                              return null;
                            },
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (error, _) =>
                              Text('Dersler yüklenemedi: $error'),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Date and time
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule),
                        title: const Text('Tarih ve Saat'),
                        subtitle: Text(_formatDateTime(_selectedDateTime)),
                        onTap: _selectDateTime,
                      ),

                      const SizedBox(height: 16),

                      // Repeat type
                      DropdownButtonFormField<RepeatType>(
                        value: _selectedRepeat,
                        decoration: const InputDecoration(
                          labelText: 'Tekrar',
                          border: OutlineInputBorder(),
                        ),
                        items: RepeatType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getRepeatText(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRepeat = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Active switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Aktif'),
                        subtitle: const Text(
                          'Hatırlatıcı bildirimlerini aç/kapat',
                        ),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isLoading ? null : _saveReminder,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.reminder != null ? 'Güncelle' : 'Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeText(ReminderType type) {
    switch (type) {
      case ReminderType.courseMorning:
        return 'Ders Sabah Hatırlatması';
      case ReminderType.coursePreStart:
        return 'Ders Öncesi Hatırlatma';
      case ReminderType.custom:
        return 'Özel Hatırlatıcı';
    }
  }

  String _getRepeatText(RepeatType type) {
    switch (type) {
      case RepeatType.once:
        return 'Tek Seferlik';
      case RepeatType.daily:
        return 'Her Gün';
      case RepeatType.weekly:
        return 'Her Hafta';
      case RepeatType.monthly:
        return 'Her Ay';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (selectedDate == today) {
      dateStr = 'Bugün';
    } else if (selectedDate == today.add(const Duration(days: 1))) {
      dateStr = 'Yarın';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '$dateStr, $timeStr';
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.reminder != null) {
        // Update existing reminder
        await ref
            .read(reminderNotifierProvider.notifier)
            .updateReminder(
              reminderId: widget.reminder!.id,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              type: _selectedType,
              courseId: _selectedCourseId,
              scheduledTime: _selectedDateTime,
              repeatType: _selectedRepeat,
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hatırlatıcı güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Add new reminder
        await ref
            .read(reminderNotifierProvider.notifier)
            .addReminder(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              type: _selectedType,
              courseId: _selectedCourseId,
              scheduledTime: _selectedDateTime,
              repeatType: _selectedRepeat,
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hatırlatıcı eklendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
