import 'package:get/get.dart';
import 'package:kitab_mandi/modules/auth/binding/auth_binding.dart';
import 'package:kitab_mandi/modules/auth/view/auth_view.dart';
import 'package:kitab_mandi/modules/wrapper/wrapper_view.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class AppPages {
  static final List<GetPage> routes = [
    // // 🌟 Splash
    GetPage(
      name: AppRoutes.wrapper, // use single wrapper screen
      page: () => const WrapperView(),
    ),

    // // 🔐 Auth
    GetPage(
      name: AppRoutes.auth, // use single auth screen
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),

    // // 🔐 Signup
    // GetPage(name: AppRoutes.signup, page: () => const SignupView()),

    // // 🏠 Home
    // GetPage(name: AppRoutes.home, page: () => const HomeView()),
  ];
}
