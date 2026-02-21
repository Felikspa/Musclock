import 'package:flutter/material.dart';
import '../../core/enums/muscle_enum.dart';
import 'app_theme_config.dart';

class AppTheme {
  // Convenience accessors for theme colors (delegated to AppThemeConfig)
  // Primary colors - Dark minimalist theme
  static const Color primaryDark = AppThemeConfig.primaryDark;
  static const Color secondaryDark = AppThemeConfig.secondaryDark;
  static const Color surfaceDark = AppThemeConfig.surfaceDark;
  static const Color cardDark = AppThemeConfig.cardDark;

  // Primary colors - Light theme
  static const Color primaryLight = AppThemeConfig.primaryLight;
  static const Color secondaryLight = AppThemeConfig.secondaryLight;
  static const Color surfaceLight = AppThemeConfig.surfaceLight;
  static const Color cardLight = AppThemeConfig.cardLight;

  // Accent color - Mint green for highlights
  static const Color accent = AppThemeConfig.accent;
  static const Color accentLight = AppThemeConfig.accentLight;

  // Text colors - Dark theme
  static const Color textPrimary = AppThemeConfig.textPrimary;
  static const Color textSecondary = AppThemeConfig.textSecondary;
  static const Color textTertiary = AppThemeConfig.textTertiary;

  // Text colors - Light theme
  static const Color textPrimaryLight = AppThemeConfig.textPrimaryLight;
  static const Color textSecondaryLight = AppThemeConfig.textSecondaryLight;
  static const Color textTertiaryLight = AppThemeConfig.textTertiaryLight;

  // Muscle group colors
  // Colors adjusted for better contrast across all themes
  // - Chest: Coral Red (#FF6B6B)
  // - Back: Teal (#00BFA5) - distinct from Shoulders
  // - Shoulders: Purple (#9C27B0) - distinct from Back green-cyan
  // - Legs: Blue (#2196F3)
  // - Arms: Deep Orange (#FF6D00) - darker yellow for visibility
  // - Glutes: Pink (#E91E63) - distinct from Chest red
  // - Abs: Amber (#FFB300) - warm tone
  static const Map<MuscleGroup, Color> muscleColors = {
    MuscleGroup.chest: Color(0xFFFF6B6B),
    MuscleGroup.back: Color(0xFF00BFA5),
    MuscleGroup.shoulders: Color(0xFF9C27B0),
    MuscleGroup.legs: Color(0xFF2196F3),
    MuscleGroup.arms: Color(0xFFFF6D00),
    MuscleGroup.glutes: Color(0xFFE91E63),
    MuscleGroup.abs: Color(0xFFFFB300),
    MuscleGroup.rest: Color(0xFF666666),
  };

  static Color getMuscleColor(MuscleGroup muscle) {
    return muscleColors[muscle] ?? accent;
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentLight,
        surface: surfaceDark,
        onPrimary: primaryDark,
        onSecondary: primaryDark,
        onSurface: textPrimary,
      ),
      appBarTheme: AppThemeConfig.getAppBarTheme(isDark: true),
      cardTheme: AppThemeConfig.getCardTheme(isDark: true),
      bottomNavigationBarTheme: AppThemeConfig.getBottomNavTheme(isDark: true),
      navigationBarTheme: AppThemeConfig.getNavBarTheme(isDark: true),
      textTheme: _buildTextTheme(isDark: true),
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: secondaryDark,
        thickness: 1,
      ),
      inputDecorationTheme: AppThemeConfig.getInputDecorationTheme(isDark: true),
      elevatedButtonTheme: AppThemeConfig.getElevatedButtonTheme(isDark: true),
      textButtonTheme: AppThemeConfig.getTextButtonTheme(),
      floatingActionButtonTheme: AppThemeConfig.getFabTheme(isDark: true),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: primaryLight,
      primaryColor: accent,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accentLight,
        surface: surfaceLight,
        onPrimary: primaryLight,
        onSecondary: primaryLight,
        onSurface: textPrimaryLight,
      ),
      appBarTheme: AppThemeConfig.getAppBarTheme(isDark: false),
      cardTheme: AppThemeConfig.getCardTheme(isDark: false),
      bottomNavigationBarTheme: AppThemeConfig.getBottomNavTheme(isDark: false),
      navigationBarTheme: AppThemeConfig.getNavBarTheme(isDark: false),
      textTheme: _buildTextTheme(isDark: false),
      iconTheme: const IconThemeData(
        color: textSecondaryLight,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: secondaryLight,
        thickness: 1,
      ),
      inputDecorationTheme: AppThemeConfig.getInputDecorationTheme(isDark: false),
      elevatedButtonTheme: AppThemeConfig.getElevatedButtonTheme(isDark: false),
      textButtonTheme: AppThemeConfig.getTextButtonTheme(),
      floatingActionButtonTheme: AppThemeConfig.getFabTheme(isDark: false),
    );
  }

  static TextTheme _buildTextTheme({required bool isDark}) {
    final primaryColor = isDark ? textPrimary : textPrimaryLight;

    return TextTheme(
      displayLarge: TextStyle(
        color: primaryColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -1,
      ),
      displayMedium: TextStyle(
        color: primaryColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        color: primaryColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: isDark ? AppThemeConfig.titleLargeDark : AppThemeConfig.titleLargeLight,
      titleMedium: isDark ? AppThemeConfig.titleMediumDark : AppThemeConfig.titleMediumLight,
      bodyLarge: TextStyle(
        color: primaryColor,
        fontSize: 16,
      ),
      bodyMedium: isDark ? AppThemeConfig.bodyMediumDark : AppThemeConfig.bodyMediumLight,
      bodySmall: isDark ? AppThemeConfig.bodySmallDark : AppThemeConfig.bodySmallLight,
    );
  }
}
