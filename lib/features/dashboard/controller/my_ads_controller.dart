import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/utils/app_snackbar.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class MyAdsController extends GetxController {
  var isLoading = false.obs;
  var myAdsList = [].obs;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    fetchMyAds();
    super.onInit();
  }

  Future<void> fetchMyAds() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;

      if (user == null) {
        throw Exception("User not logged in");
      }

      final snapshot = await _firestore
          .collection("listings")
          .where("seller.uid", isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isEmpty) {
        myAdsList.clear();
        return;
      }

      final ads = snapshot.docs.map((doc) {
        final data = doc.data();
        return ListingModel.fromMap(data);
      }).toList();

      myAdsList.assignAll(ads);
    } on FirebaseException catch (e) {
      AppSnackbar.error(_handleFirestoreError(e));
    } catch (e) {
      AppSnackbar.error("Failed to load your ads");
    } finally {
      isLoading.value = false;
    }
  }

  void editAd(ad) {
    Get.snackbar("Edit", "Edit ${ad['title']}");
  }

  void deleteAd(String id) {
    myAdsList.removeWhere((e) => e.id == id);
    Get.snackbar("Deleted", "Ad removed");
  }

  String _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return "Permission denied";
      case 'unavailable':
        return "No internet connection";
      case 'not-found':
        return "Data not found";
      default:
        return e.message ?? "Something went wrong";
    }
  }
}
