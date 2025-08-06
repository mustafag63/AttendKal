import 'package:flutter/material.dart';

class AddCoursePage extends StatelessWidget {
  const AddCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Course')),
      body: const Center(
        child: Text(
          'Add Course Form will be here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
