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
import '../services/api_service.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  final database = await DatabaseHelper.database;
  sl.registerLazySingleton<Database>(() => database);

  sl.registerLazySingleton(Dio.new);
  sl.registerLazySingleton(Connectivity.new);

  // Core services
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<ApiService>(() => ApiService());

  // Initialize API service
  await sl<ApiService>().initialize();

  // Blocs - with real dependencies
  _registerBlocs();
}

void _registerBlocs() {
  sl.registerFactory(
    () => AuthBloc(
      apiService: sl<ApiService>(),
    ),
  );

  sl.registerFactory(
    () => CoursesBloc(
      apiService: sl<ApiService>(),
    ),
  );

  sl.registerFactory(
    () => AttendanceBloc(
      apiService: sl<ApiService>(),
    ),
  );

  sl.registerFactory(
    () => SubscriptionBloc(
      apiService: sl<ApiService>(),
    ),
  );
}
