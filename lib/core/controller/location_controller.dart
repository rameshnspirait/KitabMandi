import 'package:get/get.dart';
import '../services/location_service.dart';
import '../storage/location_storage.dart';

class LocationController extends GetxController {
  RxString selectedLocation = "Select City".obs;
  RxBool isLoadingLocation = false.obs;
  RxList<String> recentLocations = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  void loadInitialData() {
    selectedLocation.value = LocationStorage.getSelected();
    recentLocations.value = LocationStorage.getRecent();
  }

  /// 📍 UPDATE LOCATION
  void updateLocation(String location) {
    selectedLocation.value = location;
    _save(location);
  }

  /// 📍 GPS LOCATION
  Future<void> detectCurrentLocation() async {
    try {
      isLoadingLocation.value = true;

      final city = await LocationService.getCurrentCity();

      if (city != null && city.isNotEmpty) {
        selectedLocation.value = city;
        _save(city);
        print(selectedLocation.value);
      } else {
        selectedLocation.value = "Unknown Location";
      }
    } catch (e) {
      selectedLocation.value = "Location Error";
    } finally {
      isLoadingLocation.value = false;
    }
  }

  /// 💾 SAVE TO HIVE
  void _save(String location) {
    LocationStorage.saveSelected(location);

    final list = recentLocations.toList();

    list.remove(location);
    list.insert(0, location);

    if (list.length > 5) {
      list.removeLast();
    }

    recentLocations.value = list;
    LocationStorage.saveRecent(list);
  }

  /// ❌ RESET
  void reset() {
    selectedLocation.value = "Select City";
    recentLocations.clear();
    LocationStorage.clear();
  }
}
