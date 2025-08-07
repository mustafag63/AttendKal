import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class LoadAttendanceEvent extends AttendanceEvent {
  final String? courseId;
  final DateTime? date;

  const LoadAttendanceEvent({this.courseId, this.date});

  @override
  List<Object> get props => [courseId ?? '', date ?? ''];
}

class MarkAttendanceEvent extends AttendanceEvent {
  final String courseId;
  final DateTime date;
  final String status;
  final String? note;
  final double? latitude;
  final double? longitude;

  const MarkAttendanceEvent({
    required this.courseId,
    required this.date,
    required this.status,
    this.note,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object> get props => [
        courseId,
        date,
        status,
        note ?? '',
        latitude ?? 0.0,
        longitude ?? 0.0,
      ];
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

class AttendanceMarked extends AttendanceState {
  final Map<String, dynamic> attendance;

  const AttendanceMarked(this.attendance);

  @override
  List<Object> get props => [attendance];
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final ApiService _apiService;

  AttendanceBloc({
    required ApiService apiService,
  })  : _apiService = apiService,
        super(AttendanceInitial()) {
    on<LoadAttendanceEvent>(_onLoadAttendance);
    on<MarkAttendanceEvent>(_onMarkAttendance);
  }

  Future<void> _onLoadAttendance(
      LoadAttendanceEvent event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final attendances = await _apiService.getAttendance(
        courseId: event.courseId,
        date: event.date,
      );
        emit(AttendanceLoaded(attendances));
    } on ApiError catch (e) {
      emit(AttendanceError(e.message ?? 'Failed to load attendance'));
    } catch (e) {
      emit(AttendanceError('An unexpected error occurred'));
    }
  }

  Future<void> _onMarkAttendance(
      MarkAttendanceEvent event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final attendanceData = {
        'courseId': event.courseId,
        'date': event.date.toIso8601String(),
        'status': event.status,
        if (event.note != null) 'note': event.note,
        if (event.latitude != null) 'latitude': event.latitude,
        if (event.longitude != null) 'longitude': event.longitude,
      };

      final attendance = await _apiService.markAttendance(attendanceData);
        emit(AttendanceMarked(attendance));
    } on ApiError catch (e) {
      emit(AttendanceError(e.message ?? 'Failed to mark attendance'));
    } catch (e) {
      emit(AttendanceError('An unexpected error occurred'));
    }
  }
}
