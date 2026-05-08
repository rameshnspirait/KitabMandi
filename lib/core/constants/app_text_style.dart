import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle heading1(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: theme.textTheme.titleLarge?.color,
    );
  }

  static TextStyle heading2(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: theme.textTheme.titleMedium?.color,
    );
  }

  static TextStyle title(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: theme.textTheme.bodyLarge?.color,
    );
  }

  static TextStyle body(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 16,
      color: theme.textTheme.bodyMedium?.color,
    );
  }

  static TextStyle subtitle(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 14,
      color: theme.textTheme.bodySmall?.color,
    );
  }

  static TextStyle caption(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(fontSize: 12, color: theme.hintColor);
  }

  static TextStyle button(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }

  /// Marketplace extras
  static TextStyle price(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );
  }

  static TextStyle tag(BuildContext context) {
    final theme = Theme.of(context);
    return GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.primary,
    );
  }
}
