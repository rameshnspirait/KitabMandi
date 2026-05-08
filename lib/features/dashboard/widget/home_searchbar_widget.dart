import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final VoidCallback? onFilterTap;
  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 6),
          ],
        ),
        child: AppTextField(
          controller: controller,
          hintText: "Search books, notes...",
          isBorderless: true,

          prefixIcon: Icon(Icons.search),
          suffixIcon: GestureDetector(
            onTap: onFilterTap,
            child: Icon(Icons.tune),
          ),
        ),
      ),
    );
  }
}
