import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/controller/filter_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<ListingModel> listings = <ListingModel>[].obs;
  RxList<ListingModel> filteredListings = <ListingModel>[].obs;

  RxString searchQuery = "".obs;
  RxBool isLoading = true.obs;
  final filterCtrl = Get.put(FilterController());

  @override
  void onInit() {
    listenListings();
    super.onInit();
  }

  ///  REAL-TIME LISTENER
  void listenListings() {
    isLoading.value = true;

    _firestore
        .collection("listings")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) {
          listings.value = snapshot.docs
              .map((doc) => ListingModel.fromMap(doc.data()))
              .toList();

          ///  APPLY SEARCH AFTER FETCH
          applyFilters();

          isLoading.value = false;
        });
  }

  void applyFilters() {
    List<ListingModel> temp = listings;

    /// 🔍 SEARCH FILTER
    if (searchQuery.value.isNotEmpty) {
      temp = temp.where((item) {
        final title = item.title.toLowerCase();
        return title.contains(searchQuery.value.toLowerCase());
      }).toList();
    }

    /// 📂 CATEGORY FILTER
    if (filterCtrl.selectedCategories.isNotEmpty) {
      temp = temp.where((item) {
        return filterCtrl.selectedCategories.contains(item.category);
      }).toList();
    }

    /// 📦 CONDITION FILTER
    if (filterCtrl.selectedConditions.isNotEmpty) {
      temp = temp.where((item) {
        return filterCtrl.selectedConditions.contains(item.condition);
      }).toList();
    }

    /// 💰 PRICE FILTER
    temp = temp.where((item) {
      final price = item.price;
      return price >= filterCtrl.minPrice.value &&
          price <= filterCtrl.maxPrice.value;
    }).toList();

    /// 🔄 SORTING
    if (filterCtrl.selectedSort.value == "Price: Low to High") {
      temp.sort((a, b) => (a.price).compareTo(b.price));
    } else if (filterCtrl.selectedSort.value == "Price: High to Low") {
      temp.sort((a, b) => (b.price).compareTo(a.price));
    } else if (filterCtrl.selectedSort.value == "Newest First") {
      temp.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
    }

    ///  FINAL RESULT
    filteredListings.value = temp;
  }

  // void applySearch() {
  //   if (searchQuery.value.isEmpty) {
  //     filteredListings.value = listings;
  //   } else {
  //     filteredListings.value = listings.where((item) {
  //       final title = item.title.toLowerCase();
  //       final sellrName = item.seller['name'].toString().toLowerCase();
  //       return title.contains(searchQuery.value.toLowerCase()) ||
  //           sellrName.contains(searchQuery.value);
  //     }).toList();
  //   }
  // }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    applyFilters();
  }

  ///  MANUAL REFRESH
  Future<void> fetchListings() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection("listings")
          .orderBy("createdAt", descending: true)
          .get();

      listings.value = snapshot.docs
          .map((doc) => ListingModel.fromMap(doc.data()))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }
}
