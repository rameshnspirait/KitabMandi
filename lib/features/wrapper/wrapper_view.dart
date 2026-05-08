import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kitab_mandi/features/auth/view/auth_view.dart';
import 'package:kitab_mandi/features/dashboard/view/dashboard_view.dart';
import 'package:kitab_mandi/features/dashboard/view/home_view.dart';

class WrapperView extends StatelessWidget {
  const WrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //  Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          //  Not logged in
          if (!snapshot.hasData) {
            return const AuthView();
          }

          //  Logged in
          return const DashboardView();
        },
      ),
    );
  }
}
