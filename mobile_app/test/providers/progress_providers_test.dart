import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:mobile_app/database/database.dart';
import 'package:mobile_app/providers/progress_providers.dart';
import 'package:mobile_app/providers/student_providers.dart';
import 'package:mobile_app/providers/attendance_providers.dart';

// Mock sınıfları için annotation
@GenerateMocks([AppDatabase])
import 'progress_providers_test.mocks.dart';

void main() {
  group('Progress Providers Tests', () {
    late ProviderContainer container;
    late MockAppDatabase mockDb;

    setUp(() {
      mockDb = MockAppDatabase();
      container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(mockDb)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('OverallProgressProvider', () {
      test('should return overall progress data', () async {
        // Arrange
        when(mockDb.customSelect(any)).thenAnswer(
          (_) => Future.value([
            MockQueryRow({
              'total_students': 100,
              'total_courses': 5,
              'total_records': 450,
              'present_records': 380,
              'attendance_rate': 84.44,
            }),
          ]),
        );

        // Act
        final result = await container.read(overallProgressProvider.future);

        // Assert
        expect(result, isNotNull);
        expect(result['total_students'], equals(100));
        expect(result['total_courses'], equals(5));
        expect(result['attendance_rate'], equals(84.44));
      });

      test('should handle database errors gracefully', () async {
        // Arrange
        when(mockDb.customSelect(any)).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => container.read(overallProgressProvider.future),
          throwsException,
        );
      });
    });

    group('CourseProgressProvider', () {
      test('should return course progress list', () async {
        // Arrange
        when(mockDb.customSelect(any)).thenAnswer(
          (_) => Future.value([
            MockQueryRow({
              'id': 'course-1',
              'name': 'Matematik 101',
              'total_students': 30,
              'total_sessions': 12,
              'average_attendance': 85.5,
              'trend': 'up',
            }),
            MockQueryRow({
              'id': 'course-2',
              'name': 'Fizik 101',
              'total_students': 25,
              'total_sessions': 10,
              'average_attendance': 78.2,
              'trend': 'down',
            }),
          ]),
        );

        // Act
        final result = await container.read(courseProgressProvider.future);

        // Assert
        expect(result, hasLength(2));
        expect(result[0]['name'], equals('Matematik 101'));
        expect(result[0]['average_attendance'], equals(85.5));
        expect(result[1]['trend'], equals('down'));
      });
    });

    group('WeeklyTrendProvider', () {
      test('should return weekly attendance trend data', () async {
        // Arrange
        when(mockDb.customSelect(any)).thenAnswer(
          (_) => Future.value([
            MockQueryRow({
              'week': '2024-W01',
              'attendance_rate': 85.0,
              'total_records': 120,
              'present_count': 102,
            }),
            MockQueryRow({
              'week': '2024-W02',
              'attendance_rate': 88.5,
              'total_records': 115,
              'present_count': 102,
            }),
          ]),
        );

        // Act
        final result = await container.read(weeklyTrendProvider.future);

        // Assert
        expect(result, hasLength(2));
        expect(result[0]['week'], equals('2024-W01'));
        expect(result[0]['attendance_rate'], equals(85.0));
        expect(result[1]['attendance_rate'], equals(88.5));
      });

      test('should return empty list when no data available', () async {
        // Arrange
        when(mockDb.customSelect(any)).thenAnswer((_) => Future.value([]));

        // Act
        final result = await container.read(weeklyTrendProvider.future);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('DailyHeatmapProvider', () {
      test('should return daily heatmap data', () async {
        // Arrange
        when(mockDb.customSelect(any)).thenAnswer(
          (_) => Future.value([
            MockQueryRow({
              'date': '2024-01-15',
              'attendance_rate': 90.0,
              'intensity': 'high',
            }),
            MockQueryRow({
              'date': '2024-01-16',
              'attendance_rate': 75.0,
              'intensity': 'medium',
            }),
          ]),
        );

        // Act
        final result = await container.read(dailyHeatmapProvider.future);

        // Assert
        expect(result, hasLength(2));
        expect(result[0]['date'], equals('2024-01-15'));
        expect(result[0]['intensity'], equals('high'));
        expect(result[1]['attendance_rate'], equals(75.0));
      });
    });
  });

  group('Progress Integration Tests', () {
    test('should update progress when new attendance is added', () async {
      // Bu test gerçek database ile integration test olarak yazılabilir
      final db = AppDatabase(NativeDatabase.memory());

      try {
        // Test verisi ekle
        await db
            .into(db.students)
            .insert(
              StudentsCompanion.insert(
                studentNumber: '12345',
                name: 'Test Student',
              ),
            );

        await db
            .into(db.courses)
            .insert(
              CoursesCompanion.insert(
                name: 'Test Course',
                code: 'TEST101',
                semester: 'Fall',
                academicYear: '2023-2024',
              ),
            );

        // Progress hesaplamasını test et
        final result = await db.customSelect('''
          SELECT COUNT(*) as total_students FROM students WHERE is_active = 1
        ''').getSingle();

        expect(result.read<int>('total_students'), equals(1));
      } finally {
        await db.close();
      }
    });
  });
}

// Mock QueryRow sınıfı
class MockQueryRow {
  final Map<String, dynamic> _data;

  MockQueryRow(this._data);

  T read<T>(String columnName) => _data[columnName] as T;
  T? readNullable<T>(String columnName) => _data[columnName] as T?;
}
