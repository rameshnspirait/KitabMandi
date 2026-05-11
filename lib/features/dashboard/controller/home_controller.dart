import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<ListingModel> listings = <ListingModel>[].obs;
  RxBool isLoading = true.obs;

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
          isLoading.value = false;
        });
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
