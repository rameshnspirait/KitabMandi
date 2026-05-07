import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';

class AppTextStyles {
  static TextStyle heading1({bool isDark = false}) => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  );

  static TextStyle heading2({bool isDark = false}) => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  );

  static TextStyle body({bool isDark = false}) => GoogleFonts.poppins(
    fontSize: 16,
    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
  );

  static TextStyle subtitle({bool isDark = false}) => GoogleFonts.poppins(
    fontSize: 14,
    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
  );

  static TextStyle caption({bool isDark = false}) => GoogleFonts.poppins(
    fontSize: 12,
    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
  );

  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
