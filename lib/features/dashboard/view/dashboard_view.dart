import 'package:flutter/material.dart';
import 'package:kitab_mandi/features/dashboard/view/cart_view.dart';
import 'package:kitab_mandi/features/dashboard/view/home_view.dart';
import 'package:kitab_mandi/features/dashboard/view/profile_view.dart';
import 'package:kitab_mandi/features/dashboard/view/search_view.dart';
import 'package:kitab_mandi/features/dashboard/widget/custom_bottom_nav.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int currentIndex = 0;

  final pages = const [HomeView(), SearchView(), CartView(), ProfileView()];

  void onTabChange(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void onCenterTap() {
    // TODO: Add your center action (e.g. Add Book / Sell)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: onTabChange,
        onCenterTap: onCenterTap,
      ),
    );
  }
}
