import 'package:hive/hive.dart';

class LocationStorage {
  static const String _boxName = 'locationBox';
  static const String _selectedKey = 'selected_location';
  static const String _recentKey = 'recent_locations';

  static const int _maxRecent = 10;

  static Box get _box => Hive.box(_boxName);

  /// 📍 Save selected locations (List)
  static void saveSelected(List<String>? locations) {
    if (locations == null || locations.isEmpty) return;

    // 🔥 Remove empty values
    final cleanList = locations.where((e) => e.isNotEmpty).toList();

    if (cleanList.isEmpty) return;

    _box.put(_selectedKey, cleanList);

    // 🔥 Auto add to recent
    for (final loc in cleanList) {
      addToRecent(loc);
    }
  }

  /// 📍 Get selected locations
  static List<String> getSelected() {
    final data = _box.get(_selectedKey);

    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }

    return [];
  }

  /// 🔥 Add to recent (no duplicates + limit)
  static void addToRecent(String location) {
    if (location.isEmpty) return;

    List<String> list = getRecent();

    // ❌ Remove duplicate
    list.remove(location);

    // ✅ Add on top
    list.insert(0, location);

    // ✂️ Limit size
    if (list.length > _maxRecent) {
      list = list.sublist(0, _maxRecent);
    }

    _box.put(_recentKey, list);
  }

  /// 📍 Get recent locations
  static List<String> getRecent() {
    final data = _box.get(_recentKey);

    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }

    return [];
  }

  /// ❌ Remove one recent item
  static void removeRecent(String location) {
    List<String> list = getRecent();
    list.remove(location);
    _box.put(_recentKey, list);
  }

  /// 🧹 Clear only recent
  static void clearRecent() {
    _box.delete(_recentKey);
  }

  /// 🧹 Clear all storage
  static void clearAll() {
    _box.clear();
  }
}
