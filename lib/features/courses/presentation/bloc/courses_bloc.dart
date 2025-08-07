import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/network/api_client.dart';

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
  final ApiClient _apiClient;

  CoursesBloc({
    required ApiClient apiClient,
    dynamic getCoursesUseCase,
    dynamic addCourseUseCase,
    dynamic deleteCourseUseCase,
  })  : _apiClient = apiClient,
        super(CoursesInitial()) {
    on<LoadCoursesEvent>(_onLoadCourses);
    on<AddCourseEvent>(_onAddCourse);
    on<DeleteCourseEvent>(_onDeleteCourse);
    on<SearchCoursesEvent>(_onSearchCourses);
  }

  void _onLoadCourses(
      LoadCoursesEvent event, Emitter<CoursesState> emit) async {
    emit(CoursesLoading());
    try {
      final response = await _apiClient.getCourses();

      if (response.success && response.data != null) {
        emit(CoursesLoaded(response.data!));
      } else {
        emit(CoursesError(response.error ?? 'Failed to load courses'));
      }
    } catch (e) {
      emit(CoursesError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onAddCourse(AddCourseEvent event, Emitter<CoursesState> emit) async {
    emit(CoursesLoading());
    try {
      final response = await _apiClient.createCourse(
        name: event.name,
        code: event.code,
        instructor: event.instructor,
        description: event.description,
        color: event.color,
        schedule: event.schedule,
      );

      if (response.success) {
        // Reload courses after successful creation
        add(LoadCoursesEvent());
      } else {
        emit(CoursesError(response.error ?? 'Failed to create course'));
      }
    } catch (e) {
      emit(CoursesError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onDeleteCourse(
      DeleteCourseEvent event, Emitter<CoursesState> emit) async {
    try {
      final response = await _apiClient.deleteCourse(event.courseId);
      
      if (response.success) {
        // Reload courses after successful deletion
        add(LoadCoursesEvent());
      } else {
        emit(CoursesError(response.error ?? 'Failed to delete course'));
      }
    } catch (e) {
      emit(CoursesError('Failed to delete course: ${e.toString()}'));
    }
  }

  void _onSearchCourses(
      SearchCoursesEvent event, Emitter<CoursesState> emit) async {
    emit(CoursesLoading());
    try {
      // Note: We need to add search parameter to getCourses in ApiClient
      final response = await _apiClient.getCourses();

      if (response.success && response.data != null) {
        // Filter courses locally for now
        final filteredCourses = response.data!.where((course) {
          final query = event.query.toLowerCase();
          final name = (course['name'] as String? ?? '').toLowerCase();
          final code = (course['code'] as String? ?? '').toLowerCase();
          final instructor =
              (course['instructor'] as String? ?? '').toLowerCase();

          return name.contains(query) ||
              code.contains(query) ||
              instructor.contains(query);
        }).toList();

        emit(CoursesLoaded(filteredCourses));
      } else {
        emit(CoursesError(response.error ?? 'Failed to search courses'));
      }
    } catch (e) {
      emit(CoursesError('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
