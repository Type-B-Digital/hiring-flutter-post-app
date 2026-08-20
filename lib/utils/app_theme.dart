import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//colors
class AppColors {
  static const primary1 = Color(0xFF41AC85);
  static const primary2 = Color(0xFF093726);
  static const secondary = Color(0xFF6C6C78);
  static const critical = Color(0xFFEB5A5A);
  static const warning = Color(0xFFFABE3C);
  static const success = Color(0xFFA4D325);
  static const line = Color(0xFFE5E5E5);
  static const onSurface = Color(0xFF131317);
  static const white = Color(0xFFFFFFFF);

  static const _loginGradientEnd = Color(0xFF397971);

  static const loginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary1, _loginGradientEnd],
  );
}

class AppTheme {
  static ThemeData lightTheme = _base(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary1,
      brightness: Brightness.light,
      primary: AppColors.primary1,
      secondary: AppColors.secondary,
      error: AppColors.critical,
      surface: AppColors.white,
      onSurface: AppColors.onSurface,
      outline: AppColors.line,
    ),
  );


  static ThemeData _base(ColorScheme colorScheme) {
    final textTheme = GoogleFonts.poppinsTextTheme();//use poppins as in the design
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.brightness == Brightness.light
            ? const Color(0xFFF5F5F6)
            : colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          side: BorderSide(color: AppColors.line),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}
