import 'package:flutter/material.dart';

class AppTheme {
  // Modern Material 3 Color Palette
  static const Color primaryColor = Color(0xFF1976D2); // Material Blue 700
  static const Color primaryLightColor = Color(0xFF42A5F5); // Material Blue 400
  static const Color primaryDarkColor = Color(0xFF0D47A1); // Material Blue 900

  static const Color secondaryColor = Color(0xFF26A69A); // Material Teal 400
  static const Color secondaryLightColor =
      Color(0xFF4DB6AC); // Material Teal 300
  static const Color secondaryDarkColor =
      Color(0xFF00695C); // Material Teal 800

  static const Color errorColor = Color(0xFFE53935); // Material Red 600
  static const Color warningColor = Color(0xFFFF9800); // Material Orange 500
  static const Color successColor = Color(0xFF43A047); // Material Green 600
  static const Color infoColor = Color(0xFF2196F3); // Material Blue 500

  // Neutral colors
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color onSurfaceColor = Color(0xFF1A1A1A);
  static const Color onBackgroundColor = Color(0xFF2C2C2C);

  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFF90CAF9); // Material Blue 200
  static const Color darkSecondaryColor =
      Color(0xFF80CBC4); // Material Teal 200
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkOnSurfaceColor = Color(0xFFE1E1E1);
  static const Color darkOnBackgroundColor = Color(0xFFE1E1E1);

  // Typography
  static const String fontFamily = 'SF Pro Display'; // iOS style font

  // Spacing
  static const double spacing2xs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacing2xl = 48.0;

  // Border radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radius2xl = 24.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primaryLightColor,
        onPrimaryContainer: primaryDarkColor,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: secondaryLightColor,
        onSecondaryContainer: secondaryDarkColor,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        surfaceContainerHighest: backgroundColor,
        onSurfaceVariant: onBackgroundColor,
        outline: Color(0xFFE0E0E0),
        outlineVariant: Color(0xFFEEEEEE),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: surfaceColor,
        surfaceTintColor: primaryColor,
        foregroundColor: onSurfaceColor,
        titleTextStyle: TextStyle(
          color: onSurfaceColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: onSurfaceColor),
        actionsIconTheme: IconThemeData(color: onSurfaceColor),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        hintStyle: TextStyle(
          color: onSurfaceColor.withOpacity(0.6),
          fontSize: 16,
          fontFamily: fontFamily,
        ),
        labelStyle: const TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: onSurfaceColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        margin: const EdgeInsets.all(spacingSm),
        clipBehavior: Clip.antiAlias,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: primaryLightColor,
        disabledColor: backgroundColor.withOpacity(0.5),
        secondarySelectedColor: secondaryLightColor,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2xl),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        height: 80,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
              fontFamily: fontFamily,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: onSurfaceColor.withOpacity(0.6),
            fontFamily: fontFamily,
          );
        }),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: onSurfaceColor.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurfaceColor,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryColor,
        onPrimary: darkBackgroundColor,
        primaryContainer: primaryDarkColor,
        onPrimaryContainer: darkPrimaryColor,
        secondary: darkSecondaryColor,
        onSecondary: darkBackgroundColor,
        secondaryContainer: secondaryDarkColor,
        onSecondaryContainer: darkSecondaryColor,
        error: errorColor,
        onError: Colors.white,
        surface: darkSurfaceColor,
        onSurface: darkOnSurfaceColor,
        surfaceContainerHighest: darkBackgroundColor,
        onSurfaceVariant: darkOnBackgroundColor,
        outline: Color(0xFF424242),
        outlineVariant: Color(0xFF2E2E2E),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: darkSurfaceColor,
        surfaceTintColor: darkPrimaryColor,
        foregroundColor: darkOnSurfaceColor,
        titleTextStyle: TextStyle(
          color: darkOnSurfaceColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: darkOnSurfaceColor),
        actionsIconTheme: IconThemeData(color: darkOnSurfaceColor),
      ),

      // Button Themes for Dark Mode
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: darkBackgroundColor,
          elevation: 2,
          shadowColor: darkPrimaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: Color(0xFF424242)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        hintStyle: TextStyle(
          color: darkOnSurfaceColor.withOpacity(0.6),
          fontSize: 16,
          fontFamily: fontFamily,
        ),
        labelStyle: const TextStyle(
          color: darkPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        margin: const EdgeInsets.all(spacingSm),
        clipBehavior: Clip.antiAlias,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPrimaryColor,
        foregroundColor: darkBackgroundColor,
        elevation: 4,
        shape: CircleBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkOnSurfaceColor,
        contentTextStyle: const TextStyle(
          color: darkBackgroundColor,
          fontSize: 16,
          fontFamily: fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper methods for consistent UI elements
  static BoxDecoration cardDecoration({bool isDark = false}) {
    return BoxDecoration(
      color: isDark ? darkSurfaceColor : surfaceColor,
      borderRadius: BorderRadius.circular(radiusXl),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : onSurfaceColor).withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration inputDecoration({bool isDark = false}) {
    return BoxDecoration(
      color: isDark ? darkBackgroundColor : backgroundColor,
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(
        color: isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
      ),
    );
  }

  // Status colors for different states
  static Color getStatusColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'present':
        return successColor;
      case 'absent':
        return errorColor;
      case 'late':
        return warningColor;
      case 'excused':
        return infoColor;
      default:
        return isDark ? darkOnSurfaceColor : onSurfaceColor;
    }
  }

  // Course colors
  static List<Color> get courseColors => [
        const Color(0xFF2196F3), // Blue
        const Color(0xFF4CAF50), // Green
        const Color(0xFFFF5722), // Deep Orange
        const Color(0xFF9C27B0), // Purple
        const Color(0xFFFF9800), // Orange
        const Color(0xFF607D8B), // Blue Grey
        const Color(0xFFE91E63), // Pink
        const Color(0xFF795548), // Brown
        const Color(0xFF3F51B5), // Indigo
        const Color(0xFF009688), // Teal
      ];
}
