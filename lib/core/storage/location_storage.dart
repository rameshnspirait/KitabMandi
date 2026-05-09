import 'package:hive/hive.dart';

class LocationStorage {
  static final Box _box = Hive.box('locationBox');

  /// Selected location
  static void saveSelected(String location) {
    _box.put('selected_location', location);
  }

  static String getSelected() {
    return _box.get('selected_location', defaultValue: 'Select City');
  }

  /// Recent locations
  static void saveRecent(List<String> list) {
    _box.put('recent_locations', list);
  }

  static List<String> getRecent() {
    return List<String>.from(_box.get('recent_locations', defaultValue: []));
  }

  static void clear() {
    _box.clear();
  }
}
