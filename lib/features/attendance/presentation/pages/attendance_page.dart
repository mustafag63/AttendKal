import 'package:flutter/material.dart';

class AttendancePage extends StatelessWidget {
  final String courseId;

  const AttendancePage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Center(
        child: Text(
          'Attendance for course: $courseId',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
