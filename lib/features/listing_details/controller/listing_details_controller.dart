import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/dashboard/controller/home_controller.dart';
import 'package:kitab_mandi/features/dashboard/model/listing_model.dart';

class ListingDetailsController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isDeleting = false.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  //=================INCREAMENT PER USER ONCE=============
  Future<void> incrementViews(String docId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('listings').doc(docId);

    final doc = await docRef.get();

    if (!doc.exists) return;

    List viewedBy = (doc.data() as Map<String, dynamic>).containsKey('viewedBy')
        ? doc['viewedBy']
        : [];

    // ✅ If already viewed → DO NOTHING
    if (viewedBy.contains(user.uid)) {
      return;
    }

    // ✅ Else → increment + add user
    await docRef.update({
      'views': FieldValue.increment(1),
      'viewedBy': FieldValue.arrayUnion([user.uid]),
    });
  }

  // ================= DELETE LISTING =================
  Future<void> deleteListing(String docId, List<String> images) async {
    try {
      isDeleting.value = true;

      // 🔥 Loader
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // ================= DELETE IMAGES =================
      for (String url in images) {
        try {
          await FirebaseStorage.instance.refFromURL(url).delete();
        } catch (e) {
          debugPrint("Image delete failed: $e");
        }
      }

      // ================= DELETE FIRESTORE DOC =================
      await FirebaseFirestore.instance
          .collection('listings')
          .doc(docId)
          .delete();

      // ================= CLOSE LOADER =================
      Get.back(); // loader
      Get.back(); // details screen

      // ================= UPDATE MY ADS LIST =================
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().fetchListings();
      }

      Get.snackbar("Deleted", "Listing removed successfully");
    } catch (e) {
      Get.back();

      Get.snackbar(
        "Error",
        "Failed to delete listing",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  // ================= CONFIRM DELETE DIALOG =================
  void confirmDelete(ListingModel ad) {
    final theme = Get.theme;
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔥 ICON
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              // 🔥 TITLE
              Text(
                "Delete Listing?",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // 🔥 DESCRIPTION
              Text(
                "This action will permanently remove your listing. This cannot be undone.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 BUTTONS
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: theme.dividerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Delete
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // close dialog
                        deleteListing(ad.id, ad.images);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: isDark ? 0 : 2,
                      ),
                      child: const Text(
                        "Remove",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
