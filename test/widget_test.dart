// This is a basic test for the AttendKal application.
// It verifies that the main application widget can be instantiated and key components work.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attendkal/main.dart';
import 'package:attendkal/core/di/injection_container.dart';

void main() {
  group('AttendKal App', () {
    testWidgets('App initializes without errors', (WidgetTester tester) async {
      // Initialize dependencies before running the app
      await initializeDependencies();

      // Build our app and trigger a frame.
      await tester.pumpWidget(const AttendKalApp());

      // Give the app time to initialize
      await tester.pumpAndSettle();

      // Verify that the app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Basic widget test', (WidgetTester tester) async {
      // Test a simple widget without dependencies
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Test'),
            ),
            body: const Center(
              child: Text('Hello World'),
            ),
          ),
        ),
      );

      // Verify our widget has expected content
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
    });
  });
}
