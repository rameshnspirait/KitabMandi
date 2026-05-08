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

  /// 🔥 NEW FEATURES
  final bool isBorderless;
  final EdgeInsetsGeometry? contentPadding;

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

    /// NEW
    this.isBorderless = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      cursorColor: theme.colorScheme.primary,
      style: AppTextStyles.body().copyWith(color: textColor),

      decoration: InputDecoration(
        isDense: true,

        hintText: hintText,
        hintStyle: AppTextStyles.subtitle().copyWith(color: theme.hintColor),

        /// ICONS
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

        filled: true,
        fillColor: theme.cardColor,

        /// 🔥 DYNAMIC PADDING
        contentPadding:
            contentPadding ??
            (isBorderless
                ? const EdgeInsets.symmetric(vertical: 12)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),

        /// 🔥 BORDER HANDLING
        border: isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.3),
                  width: 0.8,
                ),
              ),

        enabledBorder: isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.3),
                  width: 0.8,
                ),
              ),

        focusedBorder: isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.2,
                ),
              ),

        errorBorder: isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1,
                ),
              ),

        focusedErrorBorder: isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 1.2,
                ),
              ),

        errorStyle: AppTextStyles.caption().copyWith(
          color: theme.colorScheme.error,
        ),
      ),

      spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
    );
  }
}
