import 'package:flutter/material.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Courses')),
      body: const Center(
        child: Text(
          'Courses List will be displayed here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
