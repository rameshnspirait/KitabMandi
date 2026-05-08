import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: theme.hintColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Search books, notes...",
                style: TextStyle(color: theme.hintColor),
              ),
            ),
            Icon(Icons.tune, color: theme.iconTheme.color),
          ],
        ),
      ),
    );
  }
}
