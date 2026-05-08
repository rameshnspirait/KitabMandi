import 'package:get/get.dart';
import 'package:kitab_mandi/features/auth/controller/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(
      AuthController(),
      permanent: true, // 🔥 important
    );
  }
}
