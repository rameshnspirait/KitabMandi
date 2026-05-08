import 'package:flutter/material.dart';

class LocationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LocationAppBar({super.key});

  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.transparent : const Color(0xFFE5E7EB);
  }

  Color _mutedText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFB0B3B8) : const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,

      /// ✨ PREMIUM SURFACE BACKGROUND
      backgroundColor: _background(context),

      /// 🧱 SUBTLE BORDER FOR LIGHT MODE
      shape: Border(bottom: BorderSide(color: _border(context), width: 1)),

      titleSpacing: 12,

      title: Row(
        children: [
          Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20),

          const SizedBox(width: 6),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Current Location",
                style: TextStyle(fontSize: 12, color: _mutedText(context)),
              ),

              Row(
                children: [
                  Text(
                    "Vijayawada",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),

                  const Icon(Icons.keyboard_arrow_down, size: 18),
                ],
              ),
            ],
          ),
        ],
      ),

      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none, color: theme.iconTheme.color),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
