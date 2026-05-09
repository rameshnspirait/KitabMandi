import 'package:get/get.dart';

class FilterController extends GetxController {
  var selectedCategories = <String>[].obs;
  var selectedConditions = <String>[].obs;
  var selectedSort = ''.obs;

  var minPrice = 0.0.obs;
  var maxPrice = 5000.0.obs;

  void toggleItem(List<String> list, String value) {
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }
  }

  void reset() {
    selectedCategories.clear();
    selectedConditions.clear();
    selectedSort.value = '';
    minPrice.value = 0;
    maxPrice.value = 5000;
  }
}
