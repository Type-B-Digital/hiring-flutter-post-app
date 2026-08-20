import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary1 = Color(0xFF41AC85);
  static const Color white = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF6C6C78);
  static const Color onSurface = Color(0xFF131317);
  static const Color line = Color(0xFFE5E5E5);
  static const Color primary2 = Color(0xFF093726);
  static const Color critical = Color(0xFFEB5A5A);
  static const Color warning = Color(0xFFFABE3C);
  static const Color success = Color(0xFFA4D325);
  static const Color success2 = Color(0xFF188038);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color primary3 = Color(0xFF2DC28D);
  static const Color textMuted = Color(0xFFB9B9BF);
  static const Color darkText = Color(0xFF1A1A1A);
}

class AppTypography {
  static const TextStyle typography = TextStyle(
    color: AppColors.onSurface,
    fontSize: 22,
    height: 34 / 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.onSurface,
        fontSize: 34,
        height: 41 / 34,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        color: AppColors.onSurface,
        fontSize: 28,
        height: 34 / 28,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: TextStyle(
        color: AppColors.darkText,
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: TextStyle(
        color: AppColors.onSurface,
        fontSize: 20,
        height: 25 / 20,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: AppColors.darkText,
        fontSize: 18,
        height: 22 / 18,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        color: AppColors.textMuted,
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w300,
      ),
      titleSmall: TextStyle(
        color: AppColors.secondary,
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w300,
      ),
      bodyLarge: TextStyle(
        color: AppColors.onSurface,
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.secondary,
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: AppColors.secondary,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w300,
      ),
      labelLarge: TextStyle(
        color: AppColors.white,
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: AppColors.secondary,
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        color: Color(0xFF666666),
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
      ),
      titleLarge: TextStyle(
        color: AppColors.darkText,
        fontSize: 16,
        height: 21 / 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    );
  }
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary1,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.white,
        onSurface: AppColors.onSurface,
        error: AppColors.critical,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.white,
      fontFamily: GoogleFonts.lexendDeca().fontFamily,
      textTheme: AppTypography.textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary1, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.secondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary1,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
