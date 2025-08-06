import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object> get props => [];
}

class LoadCoursesEvent extends CoursesEvent {}

class AddCourseEvent extends CoursesEvent {
  final String courseName;
  final String courseCode;

  const AddCourseEvent(this.courseName, this.courseCode);

  @override
  List<Object> get props => [courseName, courseCode];
}

class DeleteCourseEvent extends CoursesEvent {
  final String courseId;

  const DeleteCourseEvent(this.courseId);

  @override
  List<Object> get props => [courseId];
}

// States
abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object> get props => [];
}

class CoursesInitial extends CoursesState {}

class CoursesLoading extends CoursesState {}

class CoursesLoaded extends CoursesState {
  final List<Map<String, dynamic>> courses;

  const CoursesLoaded(this.courses);

  @override
  List<Object> get props => [courses];
}

class CoursesError extends CoursesState {
  final String message;

  const CoursesError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  CoursesBloc({
    required dynamic getCoursesUseCase,
    required dynamic addCourseUseCase,
    required dynamic deleteCourseUseCase,
  }) : super(CoursesInitial()) {
    on<LoadCoursesEvent>(_onLoadCourses);
    on<AddCourseEvent>(_onAddCourse);
    on<DeleteCourseEvent>(_onDeleteCourse);
  }

  void _onLoadCourses(
      LoadCoursesEvent event, Emitter<CoursesState> emit) async {
    emit(CoursesLoading());
    try {
      // TODO: Implement courses loading logic
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const CoursesLoaded([]));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  void _onAddCourse(AddCourseEvent event, Emitter<CoursesState> emit) async {
    emit(CoursesLoading());
    try {
      // TODO: Implement add course logic
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const CoursesLoaded([]));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  void _onDeleteCourse(
      DeleteCourseEvent event, Emitter<CoursesState> emit) async {
    emit(CoursesLoading());
    try {
      // TODO: Implement delete course logic
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const CoursesLoaded([]));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }
}
