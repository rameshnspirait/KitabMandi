import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/controller/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
  }
}
