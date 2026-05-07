import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/core/constants/app_text_style.dart';

class AppTheme {
  // =========================
  // 🌞 LIGHT THEME
  // =========================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
    ),

    /// 🟢 AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTextStyles.heading2().copyWith(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    /// 📦 Card
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 3,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    /// 📝 Text
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.heading1(),
      headlineMedium: AppTextStyles.heading2(),
      bodyLarge: AppTextStyles.body(),
      bodyMedium: AppTextStyles.subtitle(),
      bodySmall: AppTextStyles.caption(),
    ),

    /// 🔘 Elevated Button (PRIMARY CTA → Orange)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    /// 🔲 Outlined Button (Secondary Action)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    /// 🔵 FAB (Sell Button)
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
    ),

    /// 🔤 Input Fields (Modern)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      hintStyle: AppTextStyles.subtitle(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),

    /// ➖ Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),

    /// 🎯 Icon Theme
    iconTheme: const IconThemeData(color: AppColors.iconPrimary),
  );

  // =========================
  // 🌙 DARK THEME
  // =========================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: Colors.black,
      secondary: AppColors.darkSecondary,
      onSecondary: Colors.black,
      error: AppColors.error,
      onError: Colors.white,
      background: AppColors.darkBackground,
      onBackground: AppColors.darkTextPrimary,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkTextPrimary,
    ),

    /// 🟢 AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkPrimaryDark,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: AppTextStyles.heading2(isDark: true),
      iconTheme: const IconThemeData(color: Colors.white),
    ),

    /// 📦 Card
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 2,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    /// 📝 Text
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.heading1(isDark: true),
      headlineMedium: AppTextStyles.heading2(isDark: true),
      bodyLarge: AppTextStyles.body(isDark: true),
      bodyMedium: AppTextStyles.subtitle(isDark: true),
      bodySmall: AppTextStyles.caption(isDark: true),
    ),

    /// 🔘 Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkSecondary,
        foregroundColor: Colors.black,
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    /// 🔲 Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        side: const BorderSide(color: AppColors.darkPrimary),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    /// 🔵 FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkSecondary,
      foregroundColor: Colors.black,
    ),

    /// 🔤 Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      hintStyle: AppTextStyles.subtitle(isDark: true),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
      ),
    ),

    /// ➖ Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
    ),

    /// 🎯 Icon Theme
    iconTheme: const IconThemeData(color: AppColors.darkPrimary),
  );
}
