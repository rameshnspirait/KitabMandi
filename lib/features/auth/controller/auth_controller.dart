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

  ///  UI STATE
  var isLoading = false.obs;
  var isLogin = true.obs;
  var obscurePassword = true.obs;
  var isGoogleUser = false.obs; // ✅ IMPORTANT
  final formKey = GlobalKey<FormState>();

  ///  CONTROLLERS
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Rxn<Map<String, dynamic>> userData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    fetchUserData();
    super.onInit();
  }

  /// ================= TOGGLE =================
  void toggleMode() {
    isLogin.toggle();
    isGoogleUser.value = false;

    clearFields();

    // ✅ RESET FORM STATE (VERY IMPORTANT)
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

  //===============FETCH CURRENT USERS DETAILS=============
  Future<void> fetchUserData() async {
    try {
      final user = _auth.currentUser;

      if (user == null) return;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        userData.value = doc.data();
      }
    } catch (e) {
      debugPrint("Fetch user error: $e");
    }
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

    await fetchUserData();
  }

  /// ================= SIGNUP =================
  Future<void> signUp() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final nameError = validateName(name);
    final phoneError = validatePhone(phone);
    final emailError = validateEmail(email);
    final passError = isGoogleUser.value ? null : validatePassword(password);

    if (nameError != null) return AppSnackbar.error(nameError);
    if (phoneError != null) return AppSnackbar.error(phoneError);
    if (emailError != null) return AppSnackbar.error(emailError);
    if (passError != null) return AppSnackbar.error(passError);

    try {
      isLoading.value = true;

      User? user = _auth.currentUser;

      ///  STEP 1: CREATE USER IF EMAIL SIGNUP
      if (!isGoogleUser.value) {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        user = cred.user;
      }

      ///  SAFETY CHECK
      if (user == null) {
        return AppSnackbar.error("User creation failed");
      }

      ///  STEP 2: SAVE TO FIRESTORE
      await _firestore.collection('users').doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "phone": phone,
        "email": user.email,
        "photoUrl": user.photoURL ?? "",
        "provider": isGoogleUser.value ? "google" : "email",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (isGoogleUser.value) {
        AppSnackbar.success("Account setup completed 🚀");
      }
      clearFields();
      isLogin.value = true;
      isGoogleUser.value = false;
      Get.offAllNamed(AppRoutes.wrapper);
    } catch (e) {
      AppSnackbar.error("Signup failed. ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= LOGIN =================
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final emailError = validateEmail(email);
    final passError = validatePassword(password);

    if (emailError != null) return AppSnackbar.error(emailError);
    if (passError != null) return AppSnackbar.error(passError);

    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      AppSnackbar.success("Login successful 🎉");

      Get.offAllNamed(AppRoutes.wrapper);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error("Login failed. Try again.");
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
        return AppSnackbar.error("Google sign-in cancelled");
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;

      if (user == null) throw Exception("Google login failed");

      final docRef = _firestore.collection("users").doc(user.uid);
      final doc = await docRef.get();

      ///  EXISTING USER → HOME
      if (doc.exists) {
        final data = doc.data();

        if (data?["phone"] != null && data?["phone"] != "") {
          AppSnackbar.success("Login successful 🚀");
          Get.offAllNamed(AppRoutes.wrapper);
          return;
        }
      }

      /// 🆕 NEW GOOGLE USER → SIGNUP FLOW
      isGoogleUser.value = true;
      isLogin.value = false;

      nameController.text = user.displayName ?? "";
      emailController.text = user.email ?? "";

      phoneController.clear();
      passwordController.clear();

      AppSnackbar.success("Complete your profile to continue");
    } catch (e) {
      AppSnackbar.error("Google sign-in failed");
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

      await Hive.deleteFromDisk();
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
              Text("Are you sure you want to logout?"),
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
                        Get.offAllNamed(AppRoutes.wrapper);
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
