import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kitab_mandi/core/utils/app_snackbar.dart';

class SellerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
  RxDouble lat = 0.0.obs;
  RxDouble long = 0.0.obs;

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
  final List<String> exams = [
    "SSC",
    "UPSC",
    "NEET",
    "JEE",
    "Railway",
    "Banking",
  ];

  // ================= CONDITION =================
  RxString selectedCondition = "".obs;
  final conditions = ["New", "Like New", "Used"];

  // ================= IMAGES =================
  RxList<String> images = <String>[].obs;

  Future<void> pickImage() async {
    if (images.length >= 3) {
      AppSnackbar.error("Maximum 3 images allowed");
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _compressImage(File(image.path));
      images.add(image.path);
    }
  }

  void removeImage(int index) => images.removeAt(index);

  // ================= LOCATION =================
  Future<void> detectLocation() async {
    try {
      isDetectingLocation.value = true;

      //  1. CHECK LOCATION SERVICE
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppSnackbar.error("Please enable location (GPS)");
        await Geolocator.openLocationSettings();
        return;
      }

      //  2. CHECK PERMISSION
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        AppSnackbar.error("Location permission denied");
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        AppSnackbar.error(
          "Permission permanently denied. Enable from settings.",
        );
        await Geolocator.openAppSettings();
        return;
      }

      //  3. GET LOCATION
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      //  4. GET ADDRESS
      final place = await placemarkFromCoordinates(pos.latitude, pos.longitude);

      final p = place.first;

      state.value = p.administrativeArea ?? "";
      city.value = p.locality ?? "";
      locality.value = p.subLocality ?? "";
      subLocality.value = p.subLocality ?? "";
      postalCode.value = p.postalCode ?? "";

      lat.value = pos.latitude;
      long.value = pos.longitude;

      AppSnackbar.success("Location detected successfully ✅");
    } catch (e) {
      debugPrint("Location Error: $e");
      AppSnackbar.error("Failed to detect location");
    } finally {
      isDetectingLocation.value = false;
    }
  }

  // =================  IMAGE COMPRESSION =================
  Future<File> _compressImage(File file) async {
    try {
      // 📏 ORIGINAL SIZE
      final originalSize = await file.length(); // bytes
      final originalSizeKB = originalSize / 1024;
      final originalSizeMB = originalSizeKB / 1024;

      debugPrint(
        "📸 Original Size: ${originalSizeKB.toStringAsFixed(2)} KB (${originalSizeMB.toStringAsFixed(2)} MB)",
      );

      final dir = await getTemporaryDirectory();

      final targetPath =
          "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 60, //  Best balance
      );

      if (result == null) {
        debugPrint("⚠️ Compression failed, using original image");
        return file;
      }

      final compressedFile = File(result.path);

      // 📏 COMPRESSED SIZE
      final compressedSize = await compressedFile.length();
      final compressedSizeKB = compressedSize / 1024;
      final compressedSizeMB = compressedSizeKB / 1024;

      debugPrint(
        "🗜 Compressed Size: ${compressedSizeKB.toStringAsFixed(2)} KB (${compressedSizeMB.toStringAsFixed(2)} MB)",
      );

      // 📊 SAVED DATA
      final savedKB = originalSizeKB - compressedSizeKB;
      final savedPercent = ((savedKB / originalSizeKB) * 100);

      debugPrint(
        "💾 Saved: ${savedKB.toStringAsFixed(2)} KB (${savedPercent.toStringAsFixed(2)}%)",
      );

      return compressedFile;
    } catch (e) {
      debugPrint("❌ Compression failed, using original: $e");
      return file;
    }
  }

  // ================= IMAGE UPLOAD =================
  Future<List<String>> uploadImagesToFirebase(String listingId) async {
    List<String> downloadUrls = [];

    try {
      for (int i = 0; i < images.length; i++) {
        final path = images[i];

        if (path.isEmpty) {
          throw Exception("Image path empty at index $i");
        }

        File file = File(path);

        if (!file.existsSync()) {
          throw Exception("File not found: $path");
        }

        ///  COMPRESS BEFORE UPLOAD
        file = await _compressImage(file);

        final ref = _storage
            .ref()
            .child("listings")
            .child(listingId)
            .child("image_$i.jpg");

        final metadata = SettableMetadata(contentType: "image/jpeg");
        final uploadTask = ref.putFile(file, metadata);
        uploadTask.snapshotEvents.listen((event) {
          final progress = (event.bytesTransferred / event.totalBytes) * 100;
          debugPrint("Upload [$i]: ${progress.toStringAsFixed(2)}%");
        });

        final snapshot = await uploadTask;

        if (snapshot.state == TaskState.success) {
          final url = await snapshot.ref.getDownloadURL();
          downloadUrls.add(url);
        } else {
          throw Exception("Upload failed at index $i");
        }
      }

      return downloadUrls;
    } on FirebaseException catch (e) {
      debugPrint("🔥 Firebase Error: ${e.code} - ${e.message}");
      AppSnackbar.error("Upload failed: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("🔥 Upload Error: $e");
      AppSnackbar.error("Image upload failed");
      rethrow;
    }
  }

  // ================= VALIDATION =================
  bool validate() {
    if (images.isEmpty) return _err("Add at least one image");
    if (selectedCategory.value.isEmpty) return _err("Select category");
    if (selectedEducationType.value.isEmpty) {
      return _err("Select education type");
    }
    if (!_validateEducation()) return _err("Select education detail");
    if (selectedCondition.value.isEmpty) return _err("Select condition");
    if (titleController.text.isEmpty) return _err("Enter title");
    if (priceController.text.isEmpty) return _err("Enter price");
    if (city.value.isEmpty) return _err("Select current location");
    if (descriptionController.text.isEmpty) {
      return _err("Enter description");
    }

    return true;
  }

  bool _validateEducation() {
    switch (selectedEducationType.value) {
      case "School":
        return selectedClass.value.isNotEmpty;
      case "College":
        return selectedDegree.value.isNotEmpty && selectedYear.value.isNotEmpty;
      case "Competitive Exam":
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

  // ================= UPLOAD LISTING =================
  Future<void> uploadListing() async {
    if (!validate()) return;

    try {
      isUploading.value = true;

      final user = auth.currentUser;
      if (user == null) {
        AppSnackbar.error("Login required");
        return;
      }

      final userDoc = await _firestore.collection("users").doc(user.uid).get();

      if (!userDoc.exists) {
        AppSnackbar.error("User data not found");
        return;
      }

      final userData = userDoc.data()!;

      final doc = _firestore.collection("listings").doc();

      ///  Upload Images
      final imageUrls = await uploadImagesToFirebase(doc.id);

      ///  Save Listing
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
        "images": imageUrls,
        "isSold": false,
        "location": {
          "city": city.value,
          "state": state.value,
          "locality": locality.value,
          "subLocality": subLocality.value,
          "fullAddress": fullAddress,
          "latitude": lat.value,
          "longitude": long.value,
        },
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
      AppSnackbar.success("Congratulations your ad is posted 🚀");
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
    state.value = "";
    locality.value = "";
    subLocality.value = "";
    postalCode.value = "";
  }

  static String _suffix(int i) {
    if (i == 1) return "st";
    if (i == 2) return "nd";
    if (i == 3) return "rd";
    return "th";
  }
}
