import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
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
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
    );

    _scaleAnim = Tween(begin: 1.0, end: 0.9).animate(_controller);
  }

  void _onTapSell() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onCenterTap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          ///  NOTCHED NAV BAR
          ClipPath(
            clipper: _NavBarClipper(),
            child: Container(
              height: 75,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(Icons.home, 'Home', 0, context),
                  _navItem(Icons.chat_bubble_outline, 'Chat', 1, context),

                  const SizedBox(width: 60),

                  _navItem(Icons.favorite_border, 'Wishlist', 2, context),
                  _navItem(Icons.person, 'Profile', 3, context),
                ],
              ),
            ),
          ),

          /// 🔥 FLOATING SELL BUTTON (ANIMATED)
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: _onTapSell,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Sell",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 NAV ITEM
  Widget _navItem(
    IconData icon,
    String label,
    int index,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// ✂️ CUSTOM CLIPPER FOR NOTCH
class _NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    const notchRadius = 35.0;
    final center = size.width / 2;

    path.lineTo(center - notchRadius - 10, 0);

    path.quadraticBezierTo(center - notchRadius, 0, center - notchRadius, 10);

    path.arcToPoint(
      Offset(center + notchRadius, 10),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    path.quadraticBezierTo(
      center + notchRadius,
      0,
      center + notchRadius + 10,
      0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
