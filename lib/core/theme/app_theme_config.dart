import 'package:flutter/material.dart';

/// Theme configuration helper
/// Extracts common theme configurations to reduce duplication
class AppThemeConfig {
  // ============================================
  // Brand Colors (Musclock Brand)
  // ============================================
  /// 主要品牌色 (Muscle Clock Green)
  static const Color brandPrimary = Color(0xFF00D4AA);
  static const Color brandPrimaryLight = Color(0xFF00FFD4);
  static const Color brandPrimaryDark = Color(0xFF00A080);

  /// Brand color aliases for backward compatibility
  static const Color accent = brandPrimary;
  static const Color accentLight = brandPrimaryLight;

  // ============================================
  // Theme Colors - Dark Mode
  // ============================================
  static const Color primaryDark = Color(0xFF1A1A1A);
  static const Color secondaryDark = Color(0xFF2A2A2A);
  static const Color surfaceDark = Color(0xFF333333);
  static const Color cardDark = Color(0xFF252525);

  // ============================================
  // Theme Colors - Light Mode
  // ============================================
  static const Color primaryLight = Color(0xFFF5F5F5);
  static const Color secondaryLight = Color(0xFFE0E0E0);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFAFAFA);

  // ============================================
  // Special Colors
  // ============================================
  static const Color executing = Color(0xFFFFD700);  // Gold for executing plan highlight

  // ============================================
  // Text Colors - Dark Mode
  // ============================================
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textTertiary = Color(0xFF666666);

  // ============================================
  // Text Colors - Light Mode
  // ============================================
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textTertiaryLight = Color(0xFF999999);

  // Common text styles
  static const TextStyle titleLargeDark = TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLargeLight = TextStyle(
    color: textPrimaryLight,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMediumDark = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle titleMediumLight = TextStyle(
    color: textPrimaryLight,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyMediumDark = TextStyle(
    color: textSecondary,
    fontSize: 14,
  );

  static const TextStyle bodyMediumLight = TextStyle(
    color: textSecondaryLight,
    fontSize: 14,
  );

  static const TextStyle bodySmallDark = TextStyle(
    color: textTertiary,
    fontSize: 12,
  );

  static const TextStyle bodySmallLight = TextStyle(
    color: textTertiaryLight,
    fontSize: 12,
  );

  // Common theme data
  static CardThemeData getCardTheme({required bool isDark}) {
    return CardThemeData(
      color: isDark ? cardDark : cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static InputDecorationTheme getInputDecorationTheme({required bool isDark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? surfaceDark : secondaryLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accent, width: 1),
      ),
      hintStyle: TextStyle(color: isDark ? textTertiary : textTertiaryLight),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static ElevatedButtonThemeData getElevatedButtonTheme({required bool isDark}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: isDark ? primaryDark : primaryLight,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData getTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static FloatingActionButtonThemeData getFabTheme({required bool isDark}) {
    return FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: isDark ? primaryDark : primaryLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static AppBarTheme getAppBarTheme({required bool isDark}) {
    return AppBarTheme(
      backgroundColor: isDark ? primaryDark : primaryLight,
      foregroundColor: isDark ? textPrimary : textPrimaryLight,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: isDark ? textPrimary : textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    );
  }

  static BottomNavigationBarThemeData getBottomNavTheme({required bool isDark}) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? primaryDark : surfaceLight,
      selectedItemColor: accent,
      unselectedItemColor: isDark ? textTertiary : textTertiaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }

  static NavigationBarThemeData getNavBarTheme({required bool isDark}) {
    return NavigationBarThemeData(
      backgroundColor: isDark ? primaryDark : surfaceLight,
      indicatorColor: accent.withOpacity(0.2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: accent);
        }
        return IconThemeData(color: isDark ? textTertiary : textTertiaryLight);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600);
        }
        return TextStyle(color: isDark ? textTertiary : textTertiaryLight, fontSize: 12);
      }),
    );
  }
}
