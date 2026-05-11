import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:kitab_mandi/routes/app_routes.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/validators.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        "136794753205-210rggct227ahdu5t70ckn30rejonctk.apps.googleusercontent.com",
  );

  /// UI STATE
  var isLoading = false.obs;
  var isLogin = true.obs;
  var obscurePassword = true.obs;
  var isGoogleUser = false.obs;

  final formKey = GlobalKey<FormState>();

  /// CONTROLLERS
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Rxn<Map<String, dynamic>> userData = Rxn<Map<String, dynamic>>();

  ///  FLAG TO PREVENT DUPLICATE SNACKBAR
  bool _isManualLogin = false;

  @override
  void onInit() {
    super.onInit();
    _listenAuthChanges();
  }

  ///  AUTH STATE LISTENER (SINGLE SOURCE OF TRUTH)
  void _listenAuthChanges() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await fetchUserData();

        ///  Show snackbar ONLY once
        if (_isManualLogin) {
          AppSnackbar.success("Login successful 🎉");
          _isManualLogin = false;
        }
      } else {
        userData.value = null;
      }
    });
  }

  /// ================= FETCH USER =================
  Future<void> fetchUserData() async {
    try {
      final user = _auth.currentUser;

      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        userData.value = doc.data();
        debugPrint(" User Data Loaded: ${userData.value}");
      } else {
        debugPrint(" User doc not found");
      }
    } catch (e) {
      debugPrint(" Fetch user error: $e");
    }
  }

  /// ================= TOGGLE =================
  void toggleMode() {
    isLogin.toggle();
    isGoogleUser.value = false;
    clearFields();
    formKey.currentState?.reset();
  }

  void togglePassword() {
    obscurePassword.toggle();
  }

  void clearFields() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
  }

  /// ================= VALIDATORS =================
  String? validateName(String? v) => Validators.validateName(v ?? "");
  String? validateEmail(String? v) => Validators.validateEmail(v ?? "");
  String? validatePassword(String? v) =>
      isGoogleUser.value ? null : Validators.validatePassword(v ?? "");

  String? validatePhone(String? v) {
    if (v == null || v.isEmpty) return "Enter phone number";
    if (v.length != 10) return "Enter valid 10-digit number";
    return null;
  }

  /// ================= SUBMIT =================
  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) return;

    if (isLogin.value) {
      await login();
    } else {
      await signUp();
    }
  }

  /// ================= SIGNUP =================
  Future<void> signUp() async {
    try {
      isLoading.value = true;

      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      User? user = _auth.currentUser;

      if (!isGoogleUser.value) {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = cred.user;
      }

      if (user == null) {
        AppSnackbar.error("User creation failed");
        return;
      }

      await _firestore.collection('users').doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "phone": phone,
        "email": user.email,
        "photoUrl": user.photoURL ?? "",
        "provider": isGoogleUser.value ? "google" : "email",
        "createdAt": FieldValue.serverTimestamp(),
      });

      await fetchUserData();

      ///  Only for signup (no duplication issue here)
      AppSnackbar.success("Signup successful 🚀");

      clearFields();
      isLogin.value = true;
      isGoogleUser.value = false;

      Get.offAllNamed(AppRoutes.wrapper);
    } catch (e) {
      AppSnackbar.error("Signup failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= LOGIN =================
  Future<void> login() async {
    try {
      isLoading.value = true;

      _isManualLogin = true; // 🔥 CONTROL FLAG

      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Get.offAllNamed(AppRoutes.wrapper);
    } on FirebaseAuthException catch (e) {
      _isManualLogin = false;
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      _isManualLogin = false;
      AppSnackbar.error("Login failed");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= GOOGLE LOGIN =================
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppSnackbar.error("Cancelled");
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      _isManualLogin = true; // 🔥 SAME FIX

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;

      if (user == null) throw Exception("Google login failed");

      final doc = await _firestore.collection("users").doc(user.uid).get();

      if (doc.exists && doc.data()?["phone"] != "") {
        Get.offAllNamed(AppRoutes.wrapper);
        return;
      }

      /// NEW USER FLOW
      _isManualLogin = false;

      isGoogleUser.value = true;
      isLogin.value = false;

      nameController.text = user.displayName ?? "";
      emailController.text = user.email ?? "";

      AppSnackbar.success("Complete your profile");
    } catch (e) {
      _isManualLogin = false;
      AppSnackbar.error("Google login failed");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await _auth.signOut();

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await Hive.close();

      Get.deleteAll(); // ✅ keep this
    } catch (e) {
      debugPrint("Logout Error: $e");
    }
  }

  /// ================= LOGOUT DIALOG =================
  void showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 30, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text("Logout?", style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text("Are you sure you want to logout?"),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await logout();
                      },
                      child: const Text("Logout"),
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

  /// ================= ERROR =================
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "User not found";
      case 'wrong-password':
        return "Wrong password";
      case 'email-already-in-use':
        return "Email already exists";
      case 'invalid-email':
        return "Invalid email";
      case 'weak-password':
        return "Weak password";
      default:
        return e.message ?? "Authentication failed";
    }
  }
}
