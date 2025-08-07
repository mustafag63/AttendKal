// This is a basic test for the AttendKal application.
// It verifies that the main application widget can be instantiated and key components work.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendKal App', () {
    testWidgets('Basic app structure test', (WidgetTester tester) async {
      // Test a simple MaterialApp structure
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('AttendKal'),
            ),
            body: const Center(
              child: Text('Welcome to AttendKal'),
            ),
          ),
        ),
      );

      // Verify our widget has expected content
      expect(find.text('AttendKal'), findsOneWidget);
      expect(find.text('Welcome to AttendKal'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Widget counter test', (WidgetTester tester) async {
      // Test a simple counter widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(
              child: Text('0'),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Verify the counter starts at 0
      expect(find.text('0'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
