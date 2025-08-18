import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing.dart';

class AttendkalApp extends ConsumerWidget {
  const AttendkalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Attendkal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Text', // iOS style font
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Text',
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Sabit pastel renk paleti
class AppColors {
  static const Color primary = Color(0xFF6B73FF); // Pastel mavi
  static const Color secondary = Color(0xFF9B59B6); // Pastel mor

  // 8 sabit pastel renk
  static const List<Color> courseColors = [
    Color(0xFF6B73FF), // Pastel mavi
    Color(0xFF54C6EB), // Pastel açık mavi
    Color(0xFF48CAE4), // Pastel cyan
    Color(0xFF64DFCF), // Pastel yeşil-mavi
    Color(0xFF80ED99), // Pastel yeşil
    Color(0xFFFFC09F), // Pastel turuncu
    Color(0xFFFFEE93), // Pastel sarı
    Color(0xFFADC4E8), // Pastel lavanta
  ];

  // Yardımcı renkler
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Text colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textTertiary = Color(0xFFBDC3C7);
}
