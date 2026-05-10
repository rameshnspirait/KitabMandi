import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kitab_mandi/core/utils/app_snackbar.dart';

class SellerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // ================= TEXT CONTROLLERS =================
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  // ================= LOCATION =================
  RxString state = "".obs;
  RxString city = "".obs;
  RxString locality = "".obs;
  RxString subLocality = "".obs;
  RxString postalCode = "".obs;

  RxBool isDetectingLocation = false.obs;
  RxBool isUploading = false.obs;

  String get fullAddress => [
    subLocality.value,
    locality.value,
    city.value,
    state.value,
    postalCode.value,
  ].where((e) => e.isNotEmpty).join(", ");

  // ================= CATEGORY =================
  RxString selectedCategory = "".obs;

  final List<String> categories = ["Books", "Notes", "Stationery", "Others"];

  // ================= EDUCATION =================
  RxString selectedEducationType = "".obs;

  final List<String> educationTypes = [
    "School",
    "College",
    "Competitive Exam",
    "Professional",
  ];

  // ================= SCHOOL =================
  RxString selectedClass = "".obs;

  final schoolClasses = List.generate(12, (i) => "${i + 1}${_suffix(i + 1)}");

  // ================= COLLEGE =================
  RxString selectedDegree = "".obs;
  RxString selectedYear = "".obs;

  final degrees = [
    "B.Tech",
    "B.Sc",
    "BA",
    "B.Com",
    "BBA",
    "BCA",
    "M.Tech",
    "M.Sc",
    "MBA",
  ];

  final degreeYears = {
    "B.Tech": ["1st Year", "2nd Year", "3rd Year", "4th Year"],
    "B.Sc": ["1st Year", "2nd Year", "3rd Year"],
    "BA": ["1st Year", "2nd Year", "3rd Year"],
    "B.Com": ["1st Year", "2nd Year", "3rd Year"],
    "BBA": ["1st Year", "2nd Year", "3rd Year"],
    "BCA": ["1st Year", "2nd Year", "3rd Year"],
    "M.Tech": ["1st Year", "2nd Year"],
    "M.Sc": ["1st Year", "2nd Year"],
    "MBA": ["1st Year", "2nd Year"],
  };

  // ================= EXAMS =================
  final exams = ["SSC", "UPSC", "NEET", "JEE", "Railway", "Banking"];

  // ================= CONDITION =================
  RxString selectedCondition = "".obs;

  final conditions = ["New", "Like New", "Used"];

  // ================= IMAGES =================
  RxList<String> images = <String>[].obs;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) images.add(image.path);
  }

  void removeImage(int index) => images.removeAt(index);

  // ================= LOCATION =================
  Future<void> detectLocation() async {
    try {
      isDetectingLocation.value = true;

      final pos = await Geolocator.getCurrentPosition();
      final place = await placemarkFromCoordinates(pos.latitude, pos.longitude);

      final p = place.first;

      state.value = p.administrativeArea ?? "";
      city.value = p.locality ?? "";
      locality.value = p.subLocality ?? "";
      postalCode.value = p.postalCode ?? "";
    } finally {
      isDetectingLocation.value = false;
    }
  }

  // ================= VALIDATION =================
  bool validate() {
    if (images.isEmpty) return _err("Add at least one image");
    if (selectedCategory.value.isEmpty) return _err("Select category");
    if (selectedEducationType.value.isEmpty)
      return _err("Select education type");
    if (!_validateEducation()) return _err("Select education detail");
    if (selectedCondition.value.isEmpty) return _err("Select condition");
    if (titleController.text.isEmpty) return _err("Enter title");
    if (priceController.text.isEmpty) return _err("Enter price");
    if (city.value.isEmpty) return _err("Select current location");
    if (descriptionController.text.isEmpty) return _err("Enter description");

    return true;
  }

  bool _validateEducation() {
    switch (selectedEducationType.value) {
      case "School":
        return selectedClass.value.isNotEmpty;
      case "College":
        return selectedDegree.value.isNotEmpty && selectedYear.value.isNotEmpty;
      case "Competitive Exam":
        return true;
      case "Professional":
        return true;
      default:
        return false;
    }
  }

  bool _err(String msg) {
    AppSnackbar.error(msg);
    return false;
  }

  // ================= UPLOAD =================
  Future<void> uploadListing() async {
    if (!validate()) return;

    try {
      isUploading.value = true;

      final user = auth.currentUser;
      if (user == null) {
        AppSnackbar.error("Login required");
        return;
      }

      // ✅ Fetch user data from Firestore
      final userDoc = await _firestore.collection("users").doc(user.uid).get();

      if (!userDoc.exists) {
        AppSnackbar.error("User data not found");
        return;
      }

      final userData = userDoc.data()!;

      final doc = _firestore.collection("listings").doc();

      await doc.set({
        "id": doc.id,
        "title": titleController.text,
        "price": int.tryParse(priceController.text) ?? 0,
        "category": selectedCategory.value,
        "educationType": selectedEducationType.value,
        "class": selectedClass.value,
        "degree": selectedDegree.value,
        "year": selectedYear.value,
        "condition": selectedCondition.value,
        "images": images,

        // ✅ LOCATION
        "location": {
          "city": city.value,
          "state": state.value,
          "locality": locality.value,
          "subLocality": subLocality.value,
          "fullAddress": fullAddress,
        },

        // ✅ SELLER FROM USERS COLLECTION
        "seller": {
          "uid": user.uid,
          "name": userData["name"] ?? "",
          "email": userData["email"] ?? "",
          "phone": userData["phone"] ?? "",
          "photo": userData["photoUrl"] ?? "",
        },

        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      clear();
      Get.back();
      AppSnackbar.success("Congratulations  your ads now posted 🚀");
    } catch (e) {
      AppSnackbar.error("Upload failed");
    } finally {
      isUploading.value = false;
    }
  }

  // ================= CLEAR =================
  void clear() {
    titleController.clear();
    priceController.clear();
    descriptionController.clear();

    images.clear();

    selectedCategory.value = "";
    selectedEducationType.value = "";

    selectedClass.value = "";
    selectedDegree.value = "";
    selectedYear.value = "";

    selectedCondition.value = "";

    city.value = "";
  }

  static String _suffix(int i) {
    if (i == 1) return "st";
    if (i == 2) return "nd";
    if (i == 3) return "rd";
    return "th";
  }
}
