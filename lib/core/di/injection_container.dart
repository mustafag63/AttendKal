import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

// Blocs
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/courses/presentation/bloc/courses_bloc.dart';
import '../../features/subscription/presentation/bloc/subscription_bloc.dart';

// Core
import '../database/database_helper.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../services/firebase_service.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  final database = await DatabaseHelper.database;
  sl.registerLazySingleton<Database>(() => database);

  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());

    // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService());
  
  // Blocs - using placeholder implementations
  _registerBlocs();
}

void _registerBlocs() {
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: null,
      registerUseCase: null,
      logoutUseCase: null,
    ),
  );

  sl.registerFactory(
    () => CoursesBloc(
      getCoursesUseCase: null,
      addCourseUseCase: null,
      deleteCourseUseCase: null,
    ),
  );

  sl.registerFactory(
    () => AttendanceBloc(
      markAttendanceUseCase: null,
      getAttendanceUseCase: null,
    ),
  );

  sl.registerFactory(
    () => SubscriptionBloc(
      getSubscriptionStatusUseCase: null,
      upgradeSubscriptionUseCase: null,
    ),
  );
}
