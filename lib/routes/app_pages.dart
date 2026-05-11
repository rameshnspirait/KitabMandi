import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/binding/auth_binding.dart';
import 'package:kitab_mandi/features/auth/view/auth_view.dart';
import 'package:kitab_mandi/features/dashboard/binding/dashboard_binding.dart';
import 'package:kitab_mandi/features/dashboard/binding/home_binding.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/view/dashboard_view.dart';
import 'package:kitab_mandi/features/dashboard/view/home_view.dart';
import 'package:kitab_mandi/features/seller/view/seller_listing_view.dart';
import 'package:kitab_mandi/features/splash/binding/splash_binding.dart';
import 'package:kitab_mandi/features/splash/view/splash_view.dart';
import 'package:kitab_mandi/features/wrapper/wrapper_view.dart';
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
      page: () => AuthView(),
      binding: AuthBinding(),
    ),
    // //  Dashboard
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      bindings: [DashboardBinding(), HomeBinding()],
    ),

    GetPage(
      name: AppRoutes.sellerlisting,
      page: () => SellerListingView(),
      binding: DashboardBinding(),
    ),
  ];
}
