import 'package:get/get.dart';
import '../services/location_service.dart';
import '../storage/location_storage.dart';

class LocationController extends GetxController {
  RxList<String> selectedLocations = <String>[].obs;
  RxBool isLoadingLocation = false.obs;
  RxList<String> recentLocations = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  ///  Load from storage
  void loadInitialData() {
    selectedLocations.value = LocationStorage.getSelected();
    recentLocations.value = LocationStorage.getRecent();
  }

  ///  UPDATE LOCATION (Manual select)
  void updateLocation(String location) {
    if (location.isEmpty) return;

    selectedLocations.value = [location];

    _saveSelected([location]);
  }

  ///  GPS LOCATION
  Future<void> detectCurrentLocation() async {
    try {
      isLoadingLocation.value = true;

      final city = await LocationService.getCurrentCity();

      if (city != null && city.isNotEmpty) {
        selectedLocations.value = [city];
        _saveSelected([city]);
      } else {
        selectedLocations.value = ["Unknown Location"];
      }
    } catch (e) {
      selectedLocations.value = ["Location Error"];
    } finally {
      isLoadingLocation.value = false;
    }
  }

  ///  SAVE SELECTED + UPDATE RECENT
  void _saveSelected(List<String> locations) {
    LocationStorage.saveSelected(locations);

    // Refresh recent list from storage (single source of truth)
    recentLocations.value = LocationStorage.getRecent();
  }

  ///  Remove from recent
  void removeRecent(String location) {
    LocationStorage.removeRecent(location);
    recentLocations.value = LocationStorage.getRecent();
  }

  ///  RESET ALL
  void reset() {
    selectedLocations.clear();
    recentLocations.clear();
    LocationStorage.clearAll();
  }
}
