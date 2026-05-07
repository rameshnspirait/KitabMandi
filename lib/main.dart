import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/binding/initial_binding.dart';
import 'package:kitab_mandi/core/themes/app_theme.dart';
import 'package:kitab_mandi/firebase_options.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KitabMandi',
      debugShowCheckedModeBanner: false,
      //  Theme Setup
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      //  Routing
      initialRoute: AppRoutes.splash,
      initialBinding: InitialBinding(),
      getPages: AppPages.routes,
      //  Default Transition (optional but premium feel)
      defaultTransition: Transition.cupertino,
      //  Smart back gesture handling
      popGesture: true,
    );
  }
}
