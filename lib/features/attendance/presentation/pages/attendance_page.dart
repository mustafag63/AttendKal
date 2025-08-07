import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../bloc/attendance_bloc.dart';

class AttendancePage extends StatefulWidget {
  final String courseId;

  const AttendancePage({super.key, required this.courseId});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<String, String> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    // Load attendance data for this course
    context
        .read<AttendanceBloc>()
        .add(LoadAttendanceEvent(courseId: widget.courseId));
  }

  void _markAttendance(String status) {
    if (_selectedDay == null) return;

    context.read<AttendanceBloc>().add(
          MarkAttendanceEvent(
            courseId: widget.courseId,
            status: status,
            date: _selectedDay!,
          ),
        );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return Colors.green;
      case 'ABSENT':
        return Colors.red;
      case 'LATE':
        return Colors.orange;
      case 'EXCUSED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return Icons.check_circle;
      case 'ABSENT':
        return Icons.cancel;
      case 'LATE':
        return Icons.access_time;
      case 'EXCUSED':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceMarked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Attendance marked successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AttendanceLoaded) {
            // Update local attendance data
            setState(() {
              _attendanceData.clear();
              for (final attendance in state.attendances) {
                final date = DateTime.parse(attendance['date']);
                final key = '${date.year}-${date.month}-${date.day}';
                _attendanceData[key] = attendance['status'];
              }
            });
          }
        },
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            return Column(
              children: [
                // Calendar
                Card(
                  margin: const EdgeInsets.all(16),
                  child: TableCalendar<String>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                    eventLoader: (day) {
                      final key = '${day.year}-${day.month}-${day.day}';
                      return _attendanceData[key] != null
                          ? [_attendanceData[key]!]
                          : [];
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isNotEmpty) {
                          final status = events.first;
                          return Container(
                            margin: const EdgeInsets.only(top: 5),
                            alignment: Alignment.center,
                            child: Icon(
                              _getStatusIcon(status),
                              color: _getStatusColor(status),
                              size: 16,
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      markerDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),

                // Selected Date Info
                if (_selectedDay != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Date: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Current status
                        Builder(
                          builder: (context) {
                            final key =
                                '${_selectedDay!.year}-${_selectedDay!.month}-${_selectedDay!.day}';
                            final currentStatus = _attendanceData[key];

                            if (currentStatus != null) {
                              return Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(currentStatus),
                                    color: _getStatusColor(currentStatus),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Status: ${currentStatus.toLowerCase().replaceRange(0, 1, currentStatus[0].toUpperCase())}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _getStatusColor(currentStatus),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Text(
                                'No attendance recorded',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Attendance Buttons
                if (_selectedDay != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mark Attendance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _AttendanceButton(
                                label: 'Present',
                                icon: Icons.check_circle,
                                color: Colors.green,
                                onPressed: state is AttendanceLoading
                                    ? null
                                    : () => _markAttendance('PRESENT'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AttendanceButton(
                                label: 'Absent',
                                icon: Icons.cancel,
                                color: Colors.red,
                                onPressed: state is AttendanceLoading
                                    ? null
                                    : () => _markAttendance('ABSENT'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _AttendanceButton(
                                label: 'Late',
                                icon: Icons.access_time,
                                color: Colors.orange,
                                onPressed: state is AttendanceLoading
                                    ? null
                                    : () => _markAttendance('LATE'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AttendanceButton(
                                label: 'Excused',
                                icon: Icons.info,
                                color: Colors.blue,
                                onPressed: state is AttendanceLoading
                                    ? null
                                    : () => _markAttendance('EXCUSED'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // Quick Stats
                if (state is AttendanceLoaded && state.attendances.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Stats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatsRow(state.attendances),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow(List<Map<String, dynamic>> attendances) {
    final stats = <String, int>{
      'PRESENT': 0,
      'ABSENT': 0,
      'LATE': 0,
      'EXCUSED': 0,
    };

    for (final attendance in attendances) {
      final status = attendance['status'] as String;
      stats[status] = (stats[status] ?? 0) + 1;
    }

    final total = stats.values.fold(0, (sum, count) => sum + count);
    final attendanceRate = total > 0
        ? ((stats['PRESENT']! + stats['LATE']!) / total * 100).round()
        : 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'Present',
              count: stats['PRESENT']!,
              color: Colors.green,
            ),
            _StatItem(
              label: 'Absent',
              count: stats['ABSENT']!,
              color: Colors.red,
            ),
            _StatItem(
              label: 'Late',
              count: stats['LATE']!,
              color: Colors.orange,
            ),
            _StatItem(
              label: 'Excused',
              count: stats['EXCUSED']!,
              color: Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: attendanceRate >= 75
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                attendanceRate >= 75 ? Icons.trending_up : Icons.trending_down,
                color: attendanceRate >= 75 ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                'Attendance Rate: $attendanceRate%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: attendanceRate >= 75 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _AttendanceButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
