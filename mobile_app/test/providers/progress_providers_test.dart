import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('Basic Tests', () {
    test('should pass basic test', () {
      expect(1 + 1, equals(2));
    });

    test('should handle string operations', () {
      const text = 'Attendkal';
      expect(text.length, equals(9));
      expect(text.toLowerCase(), equals('attendkal'));
    });

    test('should handle list operations', () {
      final numbers = [1, 2, 3, 4, 5];
      expect(numbers, hasLength(5));
      expect(numbers.first, equals(1));
      expect(numbers.last, equals(5));
    });

    test('should handle date operations', () {
      final now = DateTime.now();
      final timestamp = now.millisecondsSinceEpoch;
      final reconstructed = DateTime.fromMillisecondsSinceEpoch(timestamp);

      expect(reconstructed.year, equals(now.year));
      expect(reconstructed.month, equals(now.month));
      expect(reconstructed.day, equals(now.day));
    });

    test('should handle color operations', () {
      const color = Colors.blue;
      final colorValue = color;
      // ignore: deprecated_member_use
      final reconstructed = Color(colorValue.value);

      expect(reconstructed, equals(color));
    });
  });
}
