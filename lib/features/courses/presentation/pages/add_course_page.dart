import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/courses_bloc.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _instructorController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedColor = '#2196F3';
  final List<Map<String, dynamic>> _schedule = [];

  final List<String> _colors = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#9C27B0', // Purple
    '#F44336', // Red
    '#00BCD4', // Cyan
    '#795548', // Brown
    '#607D8B', // Blue Grey
  ];

  final List<String> _weekDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _instructorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addScheduleItem() {
    showDialog(
      context: context,
      builder: (context) => _ScheduleDialog(
        onAdd: (scheduleItem) {
          setState(() {
            _schedule.add(scheduleItem);
          });
        },
      ),
    );
  }

  void _removeScheduleItem(int index) {
    setState(() {
      _schedule.removeAt(index);
    });
  }

  void _saveCourse() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<CoursesBloc>().add(
            AddCourseEvent(
              name: _nameController.text.trim(),
              code: _codeController.text.trim().toUpperCase(),
              instructor: _instructorController.text.trim(),
              description: _descriptionController.text.trim(),
              color: _selectedColor,
              schedule: _schedule,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Course'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<CoursesBloc, CoursesState>(
        listener: (context, state) {
          if (state is CoursesLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Course created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is CoursesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Course Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Course Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Course Name *',
                            hintText: 'e.g., Introduction to Computer Science',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.book),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter course name';
                            }
                            if (value!.length < 2) {
                              return 'Course name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Course Code
                        TextFormField(
                          controller: _codeController,
                          decoration: const InputDecoration(
                            labelText: 'Course Code *',
                            hintText: 'e.g., CS101',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.code),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter course code';
                            }
                            if (value!.length < 2) {
                              return 'Course code must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Instructor
                        TextFormField(
                          controller: _instructorController,
                          decoration: const InputDecoration(
                            labelText: 'Instructor *',
                            hintText: 'e.g., Dr. John Smith',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter instructor name';
                            }
                            if (value!.length < 2) {
                              return 'Instructor name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Optional course description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value != null && value.length > 500) {
                              return 'Description must not exceed 500 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Color Selection Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Course Color',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          children: _colors.map((color) {
                            final isSelected = _selectedColor == color;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse(color.substring(1), radix: 16) +
                                        0xFF000000,
                                  ),
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.black, width: 3)
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 24,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Schedule Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Class Schedule',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _addScheduleItem,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Schedule'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_schedule.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No schedule added yet',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Tap "Add Schedule" to set class times',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...List.generate(_schedule.length, (index) {
                            final item = _schedule[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Color(
                                    int.parse(_selectedColor.substring(1),
                                            radix: 16) +
                                        0xFF000000,
                                  ),
                                  child: Text(
                                    _weekDays[item['dayOfWeek']]
                                        .substring(0, 3),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(_weekDays[item['dayOfWeek']]),
                                subtitle: Text(
                                  '${item['startTime']} - ${item['endTime']}${item['room'] != null ? ' • ${item['room']}' : ''}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _removeScheduleItem(index),
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<CoursesBloc, CoursesState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is CoursesLoading ? null : _saveCourse,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(
                            int.parse(_selectedColor.substring(1), radix: 16) +
                                0xFF000000,
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: state is CoursesLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Create Course',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const _ScheduleDialog({required this.onAdd});

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  int _selectedDay = 1; // Monday
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);
  final _roomController = TextEditingController();

  final List<String> _weekDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  void _addSchedule() {
    if (_endTime.hour < _startTime.hour ||
        (_endTime.hour == _startTime.hour &&
            _endTime.minute <= _startTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final scheduleItem = {
      'dayOfWeek': _selectedDay,
      'startTime':
          '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
      'endTime':
          '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
      if (_roomController.text.isNotEmpty) 'room': _roomController.text.trim(),
    };

    widget.onAdd(scheduleItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Class Schedule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day Selection
            DropdownButtonFormField<int>(
              value: _selectedDay,
              decoration: const InputDecoration(
                labelText: 'Day of Week',
                border: OutlineInputBorder(),
              ),
              items: List.generate(_weekDays.length, (index) {
                return DropdownMenuItem(
                  value: index,
                  child: Text(_weekDays[index]),
                );
              }),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Start Time
            InkWell(
              onTap: () => _selectTime(true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(_startTime.format(context)),
              ),
            ),
            const SizedBox(height: 16),

            // End Time
            InkWell(
              onTap: () => _selectTime(false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(_endTime.format(context)),
              ),
            ),
            const SizedBox(height: 16),

            // Room (Optional)
            TextFormField(
              controller: _roomController,
              decoration: const InputDecoration(
                labelText: 'Room (Optional)',
                hintText: 'e.g., Room 101',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addSchedule,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
