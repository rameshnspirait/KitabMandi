import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/validators.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;

  // 🔐 SIGNUP
  Future<void> signUp(String name, String email, String password) async {
    // Validation
    final nameError = Validators.validateName(name);
    final emailError = Validators.validateEmail(email);
    final passError = Validators.validatePassword(password);

    if (nameError != null) {
      AppSnackbar.error(nameError);
      return;
    }
    if (emailError != null) {
      AppSnackbar.error(emailError);
      return;
    }
    if (passError != null) {
      AppSnackbar.error(passError);
      return;
    }

    try {
      isLoading.value = true;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      await _firestore.collection('users').doc(user.uid).set({
        "uid": user.uid,
        "name": name,
        "email": email,
        "createdAt": FieldValue.serverTimestamp(),
      });

      AppSnackbar.success("Account created successfully");
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error("Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  // 🔐 LOGIN
  Future<void> login(String email, String password) async {
    final emailError = Validators.validateEmail(email);
    final passError = Validators.validatePassword(password);

    if (emailError != null) {
      AppSnackbar.error(emailError);
      return;
    }
    if (passError != null) {
      AppSnackbar.error(passError);
      return;
    }

    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      AppSnackbar.success("Login successful");
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error("Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  // 🔥 ERROR HANDLER
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "Email already registered";
      case 'invalid-email':
        return "Invalid email format";
      case 'user-not-found':
        return "No user found";
      case 'wrong-password':
        return "Incorrect password";
      case 'weak-password':
        return "Password too weak";
      default:
        return "Authentication failed";
    }
  }
}
