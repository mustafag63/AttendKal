import 'package:equatable/equatable.dart';

class Course extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String code;
  final String instructor;
  final CourseSchedule schedule;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
    required this.id,
    required this.userId,
    required this.name,
    required this.code,
    required this.instructor,
    required this.schedule,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    code,
    instructor,
    schedule,
    color,
    createdAt,
    updatedAt,
  ];

  Course copyWith({
    String? id,
    String? userId,
    String? name,
    String? code,
    String? instructor,
    CourseSchedule? schedule,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      code: code ?? this.code,
      instructor: instructor ?? this.instructor,
      schedule: schedule ?? this.schedule,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CourseSchedule extends Equatable {
  final List<String> daysOfWeek; // ['Monday', 'Wednesday', 'Friday']
  final String startTime; // '09:00'
  final String endTime; // '10:30'
  final String? room;

  const CourseSchedule({
    required this.daysOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
  });

  @override
  List<Object?> get props => [daysOfWeek, startTime, endTime, room];

  CourseSchedule copyWith({
    List<String>? daysOfWeek,
    String? startTime,
    String? endTime,
    String? room,
  }) {
    return CourseSchedule(
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
    );
  }

  // Helper methods
  bool isToday() {
    final now = DateTime.now();
    final today = _getDayName(now.weekday);
    return daysOfWeek.contains(today);
  }

  bool isThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    for (int i = 0; i <= 6; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayName = _getDayName(day.weekday);
      if (daysOfWeek.contains(dayName)) {
        return true;
      }
    }
    return false;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String get formattedDays {
    if (daysOfWeek.isEmpty) return '';
    if (daysOfWeek.length == 1) return daysOfWeek.first;
    return daysOfWeek.join(', ');
  }

  String get formattedTime {
    return '$startTime - $endTime';
  }

  String get fullSchedule {
    final days = formattedDays;
    final time = formattedTime;
    final roomText = room?.isNotEmpty == true ? ' (Room: $room)' : '';
    return '$days $time$roomText';
  }
}
