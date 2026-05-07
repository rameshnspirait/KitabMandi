import 'package:get/get.dart';
import 'package:kitab_mandi/modules/auth/binding/auth_binding.dart';
import 'package:kitab_mandi/modules/auth/view/auth_view.dart';
import 'package:kitab_mandi/modules/splash/binding/splash_binding.dart';
import 'package:kitab_mandi/modules/splash/view/splash_view.dart';
import 'package:kitab_mandi/modules/wrapper/wrapper_view.dart';
import 'package:kitab_mandi/routes/app_routes.dart';

class AppPages {
  static final List<GetPage> routes = [
    //  Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(name: AppRoutes.wrapper, page: () => const WrapperView()),
    // //  Auth
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
  ];
}
