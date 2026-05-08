import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  var isLoading = false.obs;

  //  SIGNUP
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
      Get.offAllNamed(AppRoutes.dashboard);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error("Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  //  LOGIN
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
      Get.offAllNamed(AppRoutes.dashboard);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(_handleAuthError(e));
    } catch (e) {
      AppSnackbar.error("Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= GOOGLE SIGN-IN (FIXED) =================
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      //  Force logout (optional but good for clean login)
      await _googleSignIn.signOut();

      //  Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppSnackbar.error("Google sign-in cancelled");

        return;
      }

      //  Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        AppSnackbar.error("ID Token is null");
        return;
      }

      //  Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      //  Firebase sign-in
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCred.user;

      if (user == null) {
        AppSnackbar.error("Firebase login failed");
        return;
      }

      //  Firestore user creation
      final docRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid);

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

      AppSnackbar.success("Google login successful");
      Get.offAllNamed(AppRoutes.dashboard);
    } on FirebaseAuthException catch (e) {
      AppSnackbar.error(e.message ?? "Auth failed");
    } catch (e) {
      AppSnackbar.error("An error occurred");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= ERROR HANDLER =================
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
      case 'invalid-credential':
        return "Invalid credentials";
      default:
        return e.message ?? "Authentication failed";
    }
  }
}
