import 'package:get/get.dart';
import '../services/location_service.dart';

class LocationController extends GetxController {
  RxString selectedLocation = "Select City".obs;
  RxBool isLoadingLocation = false.obs;

  void updateLocation(String location) {
    selectedLocation.value = location;
  }

  /// 🔥 REAL GPS LOCATION
  Future<void> detectCurrentLocation() async {
    try {
      isLoadingLocation.value = true;

      final city = await LocationService.getCurrentCity();

      if (city != null) {
        selectedLocation.value = city;
      } else {
        selectedLocation.value = "Unknown Location";
      }
    } catch (e) {
      selectedLocation.value = "Location Error";
    } finally {
      isLoadingLocation.value = false;
    }
  }
}
