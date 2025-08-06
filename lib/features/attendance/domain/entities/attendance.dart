import 'package:equatable/equatable.dart';

enum AttendanceStatus {
  present,
  absent,
  late,
  excused;

  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  String get value {
    return name;
  }

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AttendanceStatus.absent,
    );
  }
}

class Attendance extends Equatable {
  final String id;
  final String courseId;
  final DateTime date;
  final AttendanceStatus status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Attendance({
    required this.id,
    required this.courseId,
    required this.date,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    courseId,
    date,
    status,
    note,
    createdAt,
    updatedAt,
  ];

  Attendance copyWith({
    String? id,
    String? courseId,
    DateTime? date,
    AttendanceStatus? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isPresent =>
      status == AttendanceStatus.present || status == AttendanceStatus.late;
  bool get isAbsent => status == AttendanceStatus.absent;
  bool get isExcused => status == AttendanceStatus.excused;

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get weekday {
    switch (date.weekday) {
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
}

class AttendanceStats extends Equatable {
  final int totalClasses;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int excusedCount;

  const AttendanceStats({
    required this.totalClasses,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.excusedCount,
  });

  @override
  List<Object?> get props => [
    totalClasses,
    presentCount,
    absentCount,
    lateCount,
    excusedCount,
  ];

  double get attendancePercentage {
    if (totalClasses == 0) return 0.0;
    return ((presentCount + lateCount) / totalClasses) * 100;
  }

  double get absentPercentage {
    if (totalClasses == 0) return 0.0;
    return (absentCount / totalClasses) * 100;
  }

  String get formattedAttendancePercentage {
    return '${attendancePercentage.toStringAsFixed(1)}%';
  }

  bool get isGoodAttendance => attendancePercentage >= 75.0;
  bool get isWarningAttendance =>
      attendancePercentage >= 60.0 && attendancePercentage < 75.0;
  bool get isPoorAttendance => attendancePercentage < 60.0;
}
