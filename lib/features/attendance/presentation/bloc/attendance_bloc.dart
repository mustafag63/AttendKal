import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/network/api_client.dart';

// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class LoadAttendanceEvent extends AttendanceEvent {
  final String? courseId;

  const LoadAttendanceEvent({this.courseId});

  @override
  List<Object> get props => [courseId ?? ''];
}

class MarkAttendanceEvent extends AttendanceEvent {
  final String courseId;
  final String status;
  final DateTime date;
  final String? note;

  const MarkAttendanceEvent({
    required this.courseId,
    required this.status,
    required this.date,
    this.note,
  });

  @override
  List<Object> get props => [courseId, status, date, note ?? ''];
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
  final List<Map<String, dynamic>> attendances;

  const AttendanceLoaded(this.attendances);

  @override
  List<Object> get props => [attendances];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object> get props => [message];
}

class AttendanceMarked extends AttendanceState {
  final Map<String, dynamic> attendance;

  const AttendanceMarked(this.attendance);

  @override
  List<Object> get props => [attendance];
}

// BLoC
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final ApiClient _apiClient;

  AttendanceBloc({
    required ApiClient apiClient,
    dynamic markAttendanceUseCase,
    dynamic getAttendanceUseCase,
  })  : _apiClient = apiClient,
        super(AttendanceInitial()) {
    on<LoadAttendanceEvent>(_onLoadAttendance);
    on<MarkAttendanceEvent>(_onMarkAttendance);
  }

  void _onLoadAttendance(
      LoadAttendanceEvent event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final response = await _apiClient.getAttendance(courseId: event.courseId);

      if (response.success && response.data != null) {
        emit(AttendanceLoaded(response.data!));
      } else {
        emit(AttendanceError(response.error ?? 'Failed to load attendance'));
      }
    } catch (e) {
      emit(AttendanceError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onMarkAttendance(
      MarkAttendanceEvent event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final response = await _apiClient.markAttendance(
        courseId: event.courseId,
        status: event.status,
        date: event.date,
        note: event.note,
      );

      if (response.success && response.data != null) {
        emit(AttendanceMarked(response.data!));
        // Reload attendance after marking
        add(LoadAttendanceEvent(courseId: event.courseId));
      } else {
        emit(AttendanceError(response.error ?? 'Failed to mark attendance'));
      }
    } catch (e) {
      emit(AttendanceError('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
