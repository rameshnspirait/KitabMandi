import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<ListingModel> listings = <ListingModel>[].obs;
  RxList<ListingModel> filteredListings = <ListingModel>[].obs;

  RxString searchQuery = "".obs;
  RxBool isLoading = true.obs;

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
          applySearch();

          isLoading.value = false;
        });
  }

  void applySearch() {
    if (searchQuery.value.isEmpty) {
      filteredListings.value = listings;
    } else {
      filteredListings.value = listings.where((item) {
        final title = item.title.toLowerCase();
        final sellrName = item.seller['name'].toString().toLowerCase();
        return title.contains(searchQuery.value.toLowerCase()) ||
            sellrName.contains(searchQuery.value);
      }).toList();
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    applySearch();
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
