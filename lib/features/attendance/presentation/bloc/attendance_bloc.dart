import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class LoadAttendanceEvent extends AttendanceEvent {
  final String courseId;

  const LoadAttendanceEvent(this.courseId);

  @override
  List<Object> get props => [courseId];
}

class MarkAttendanceEvent extends AttendanceEvent {
  final String courseId;
  final String status;
  final DateTime date;

  const MarkAttendanceEvent(this.courseId, this.status, this.date);

  @override
  List<Object> get props => [courseId, status, date];
}

// States
abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<Map<String, dynamic>> attendanceList;

  const AttendanceLoaded(this.attendanceList);

  @override
  List<Object> get props => [attendanceList];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  AttendanceBloc({
    required dynamic markAttendanceUseCase,
    required dynamic getAttendanceUseCase,
  }) : super(AttendanceInitial()) {
    on<LoadAttendanceEvent>(_onLoadAttendance);
    on<MarkAttendanceEvent>(_onMarkAttendance);
  }

  void _onLoadAttendance(
      LoadAttendanceEvent event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      // TODO: Implement attendance loading logic
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const AttendanceLoaded([]));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  void _onMarkAttendance(
      MarkAttendanceEvent event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      // TODO: Implement mark attendance logic
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const AttendanceLoaded([]));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}
