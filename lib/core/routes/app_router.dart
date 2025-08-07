import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/courses/presentation/pages/add_course_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri}" could not be found.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      
      // If we're on splash page, let it handle the redirect
      if (state.uri.path == '/') {
        return null;
      }
      
      // If user is authenticated and trying to access auth pages, redirect to home
      if (authState is AuthAuthenticated) {
        if (state.uri.path == '/login' || state.uri.path == '/register') {
          return '/home';
        }
      }
      
      // If user is not authenticated and trying to access protected pages, redirect to login
      if (authState is AuthUnauthenticated || authState is AuthInitial) {
        if (state.uri.path != '/login' && state.uri.path != '/register') {
          return '/login';
        }
      }
      
      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Main app
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Courses
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (context, state) => const CoursesPage(),
      ),
      GoRoute(
        path: '/add-course',
        name: 'addCourse',
        builder: (context, state) => const AddCoursePage(),
      ),

      // Attendance
      GoRoute(
        path: '/attendance/:courseId',
        name: 'attendance',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return AttendancePage(courseId: courseId);
        },
      ),

      // Analytics
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsPage(),
      ),

      // Subscription
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionPage(),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
