import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCenterTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 70,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 0, context),
          _navItem(Icons.search, 1, context),

          /// CENTER BUTTON
          GestureDetector(
            onTap: onCenterTap,
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),

          _navItem(Icons.shopping_cart, 2, context),
          _navItem(Icons.person, 3, context),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index, BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Icon(
            icon,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.iconTheme.color,
          ),
        ),
      ),
    );
  }
}
