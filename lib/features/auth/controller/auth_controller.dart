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

  /// 🔹 UI STATE
  var isLoading = false.obs;
  var isLogin = true.obs;
  var obscurePassword = true.obs;

  /// 🔹 FORM CONTROLLERS
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final forgotPassword = TextEditingController();

  /// ================= TOGGLE =================
  void toggleMode() {
    isLogin.toggle();
    clearFields();
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
  String? validatePassword(String? v) => Validators.validatePassword(v ?? "");

  String? validatePhone(String? v) {
    if (v == null || v.isEmpty) return "Enter phone number";
    if (v.length != 10) return "Enter valid 10-digit number";
    return null;
  }

  /// ================= SUBMIT =================
  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (isLogin.value) {
      await login();
    } else {
      await signUp();
    }
  }

  /// ================= SIGNUP =================
  Future<void> signUp() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final nameError = validateName(name);
    final emailError = validateEmail(email);
    final passError = validatePassword(password);
    final phoneError = validatePhone(phone);

    if (nameError != null) return AppSnackbar.error(nameError);
    if (phoneError != null) return AppSnackbar.error(phoneError);
    if (emailError != null) return AppSnackbar.error(emailError);
    if (passError != null) return AppSnackbar.error(passError);

    try {
      isLoading.value = true;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) throw Exception("User creation failed");

      await _firestore.collection('users').doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "phone": phone,
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      AppSnackbar.success("Account created successfully 🚀");

      isLogin.value = true;
      clearFields();
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error("Signup failed. Try again.");
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

      if (!doc.exists) {
        await docRef.set({
          "uid": user.uid,
          "name": user.displayName ?? "User",
          "email": user.email ?? "",
          "photoUrl": user.photoURL ?? "",
          "provider": "google",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      AppSnackbar.success("Google login successful 🚀");
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
              /// ICON
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              /// TITLE
              Text(
                "Logout?",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// SUBTITLE
              Text(
                "Are you sure you want to logout from your account?",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),

              const SizedBox(height: 20),

              /// BUTTONS
              Row(
                children: [
                  /// CANCEL
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// LOGOUT
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

  /// ================= ERROR HANDLER =================
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
