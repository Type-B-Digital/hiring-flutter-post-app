import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get titleMedium => GoogleFonts.lexendDeca(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static TextStyle get callOutBold => GoogleFonts.lexendDeca(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle get bodyLight => GoogleFonts.lexendDeca(
    fontSize: 14,
    fontWeight: FontWeight.w100,
    color: AppColors.secondary,
  );

  static TextStyle get footnoteLight => GoogleFonts.lexendDeca(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.secondary,
  );

  static TextStyle get footnoteMedium => GoogleFonts.lexendDeca(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
  );

  static TextStyle get footnoteRegular =>
      GoogleFonts.lexendDeca(fontSize: 14, color: AppColors.secondary);

  static TextStyle get captionLight => GoogleFonts.lexendDeca(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: AppColors.secondary,
  );

  static TextStyle get title => GoogleFonts.lexendDeca(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle get titleBold => GoogleFonts.lexendDeca(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle get calloutSemibold => GoogleFonts.lexendDeca(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
}
