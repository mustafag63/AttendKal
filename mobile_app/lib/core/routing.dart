import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/bottom_nav/bottom_nav_screen.dart';
import '../features/courses/screens/courses_screen.dart';
import '../features/courses/screens/add_course_screen.dart';
import '../features/courses/screens/course_detail_screen.dart';
import '../features/courses/screens/edit_course_screen.dart';
import '../features/reminders/reminders_screen.dart';
import '../features/attendance/today_attendance_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../providers/auth_providers.dart';

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoginPage = state.matchedLocation == '/login';
      final isRegisterPage = state.matchedLocation == '/register';
      final isAuthPage = isLoginPage || isRegisterPage;

      // If user is not authenticated and not on auth pages, redirect to login
      if (authState is AuthUnauthenticated && !isAuthPage) {
        return '/login';
      }

      // If user is authenticated and on auth pages, redirect to home
      if (authState is AuthAuthenticated && isAuthPage) {
        return '/';
      }

      return null; // No redirect needed
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Ana shell route - Bottom Navigation
      ShellRoute(
        builder: (context, state, child) {
          return BottomNavScreen(child: child);
        },
        routes: [
          // Derslerim
          GoRoute(
            path: '/',
            name: 'courses',
            builder: (context, state) => const CoursesScreen(),
            routes: [
              // Ders ekleme
              GoRoute(
                path: 'add',
                name: 'add-course',
                builder: (context, state) => const AddCourseScreen(),
              ),
              // Ders detayı
              GoRoute(
                path: ':courseId',
                name: 'course-detail',
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  return CourseDetailScreen(courseId: courseId);
                },
                routes: [
                  // Ders düzenleme
                  GoRoute(
                    path: 'edit',
                    name: 'edit-course',
                    builder: (context, state) {
                      final courseId = state.pathParameters['courseId']!;
                      return EditCourseScreen(courseId: courseId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Hatırlatıcı
          GoRoute(
            path: '/reminders',
            name: 'reminders',
            builder: (context, state) => const RemindersScreen(),
          ),

          // Bugünkü Dersler - Attendance
          GoRoute(
            path: '/today',
            name: 'today',
            builder: (context, state) => const TodayAttendanceScreen(),
          ),

          // İlerleme
          GoRoute(
            path: '/progress',
            name: 'progress',
            builder: (context, state) => const ProgressScreen(),
          ),

          // Profil
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Sayfa bulunamadı: ${state.matchedLocation}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Navigation helper
class AppNavigation {
  static void goToCourses(BuildContext context) {
    context.go('/');
  }

  static void goToReminders(BuildContext context) {
    context.go('/reminders');
  }

  static void goToProgress(BuildContext context) {
    context.go('/progress');
  }

  static void goToProfile(BuildContext context) {
    context.go('/profile');
  }
}
