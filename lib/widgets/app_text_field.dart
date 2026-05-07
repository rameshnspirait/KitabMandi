import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/constants/app_text_style.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      style: AppTextStyles.body(),

      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.subtitle(),

        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

        filled: true,

        // 🔥 THEME-BASED BACKGROUND (LIGHT + DARK)
        fillColor: theme.cardColor,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        // 🔥 DEFAULT BORDER (thin, subtle)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.dividerColor.withOpacity(0.3),
            width: 0.8,
          ),
        ),

        // 🔥 ENABLED BORDER
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.dividerColor.withOpacity(0.3),
            width: 0.8,
          ),
        ),

        // 🔥 FOCUSED BORDER
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.2),
        ),

        // 🔥 ERROR BORDER
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
        ),

        // 🔥 FOCUSED ERROR BORDER
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.2),
        ),

        // 🔥 ERROR TEXT STYLE
        errorStyle: AppTextStyles.caption().copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
