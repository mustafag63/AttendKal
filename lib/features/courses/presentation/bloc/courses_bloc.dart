import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

// Events
abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object> get props => [];
}

class LoadCoursesEvent extends CoursesEvent {}

class AddCourseEvent extends CoursesEvent {
  final String name;
  final String code;
  final String instructor;
  final String description;
  final String color;
  final List<Map<String, dynamic>> schedule;

  const AddCourseEvent({
    required this.name,
    required this.code,
    required this.instructor,
    required this.description,
    required this.color,
    required this.schedule,
  });

  @override
  List<Object> get props =>
      [name, code, instructor, description, color, schedule];
}

class DeleteCourseEvent extends CoursesEvent {
  final String courseId;

  const DeleteCourseEvent(this.courseId);

  @override
  List<Object> get props => [courseId];
}

class SearchCoursesEvent extends CoursesEvent {
  final String query;

  const SearchCoursesEvent(this.query);

  @override
  List<Object> get props => [query];
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
  final ApiService _apiService;

  CoursesBloc({
    required ApiService apiService,
  })  : _apiService = apiService,
        super(CoursesInitial()) {
    on<LoadCoursesEvent>(_onLoadCourses);
    on<AddCourseEvent>(_onAddCourse);
    on<DeleteCourseEvent>(_onDeleteCourse);
    on<SearchCoursesEvent>(_onSearchCourses);
  }

  Future<void> _onLoadCourses(
      LoadCoursesEvent event, Emitter<CoursesState> emit) async {
    emit(CoursesLoading());
    try {
      final courses = await _apiService.getCourses();
      emit(CoursesLoaded(courses));
    } on ApiError catch (e) {
      emit(CoursesError(e.message ?? 'Failed to load courses'));
    } catch (e) {
      emit(CoursesError('An unexpected error occurred'));
    }
  }

  Future<void> _onAddCourse(
      AddCourseEvent event, Emitter<CoursesState> emit) async {
    emit(CoursesLoading());
    try {
      final courseData = {
        'name': event.name,
        'code': event.code,
        'instructor': event.instructor,
        'description': event.description,
        'color': event.color,
        'schedule': event.schedule,
      };

      await _apiService.createCourse(courseData);

      // Reload courses after adding
      final courses = await _apiService.getCourses();
      emit(CoursesLoaded(courses));
    } on ApiError catch (e) {
      emit(CoursesError(e.message ?? 'Failed to add course'));
    } catch (e) {
      emit(CoursesError('An unexpected error occurred'));
    }
  }

  Future<void> _onDeleteCourse(
      DeleteCourseEvent event, Emitter<CoursesState> emit) async {
    final currentState = state;
    if (currentState is CoursesLoaded) {
      emit(CoursesLoading());
      try {
        await _apiService.deleteCourse(event.courseId);

        // Reload courses after deleting
        final courses = await _apiService.getCourses();
        emit(CoursesLoaded(courses));
      } on ApiError catch (e) {
        emit(CoursesError(e.message ?? 'Failed to delete course'));
        // Restore previous state on error
        emit(currentState);
      } catch (e) {
        emit(CoursesError('An unexpected error occurred'));
        // Restore previous state on error
        emit(currentState);
      }
    }
  }

  Future<void> _onSearchCourses(
      SearchCoursesEvent event, Emitter<CoursesState> emit) async {
    final currentState = state;
    if (currentState is CoursesLoaded) {
      if (event.query.isEmpty) {
        // Show all courses if query is empty
        emit(currentState);
        return;
      }

      final filteredCourses = currentState.courses.where((course) {
        final name = course['name']?.toString().toLowerCase() ?? '';
        final code = course['code']?.toString().toLowerCase() ?? '';
        final instructor = course['instructor']?.toString().toLowerCase() ?? '';
        final query = event.query.toLowerCase();

        return name.contains(query) ||
            code.contains(query) ||
            instructor.contains(query);
      }).toList();

      emit(CoursesLoaded(filteredCourses));
    }
  }
}
