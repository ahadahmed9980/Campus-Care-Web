import 'package:customer_care_webapp/services/admin_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final rememberMe = false.obs;
  final obscurePassword = true.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final _adminAuth = AdminAuthService.instance;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // ── Validators ─────────────────────────────────────────────────────────────

  void toggleRememberMe(bool? value) => rememberMe.value = value ?? false;

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(email)) return 'Enter a valid email address';

    // Show the domain error inline in the field while typing (dev mode
    // returns null so the field stays clean during development).
    return _adminAuth.checkDomain(email);
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // ── Email / password sign-in ───────────────────────────────────────────────

  Future<bool> signIn() async {
    errorMessage.value = '';
    if (!(formKey.currentState?.validate() ?? false)) return false;

    isLoading.value = true;
    try {
      await _adminAuth.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
        rememberMe: rememberMe.value,
      );
      return true;
    } on AdminAuthException catch (e) {
      errorMessage.value = e.message;
      return false;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _mapAuthError(e);
      return false;
    } catch (e) {
      errorMessage.value = 'Unable to sign in. Please try again.';
      debugPrint(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Google sign-in ─────────────────────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      return await _adminAuth.signInWithGoogle();
    } on AdminAuthException catch (e) {
      errorMessage.value = e.message;
      return false;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _mapAuthError(e);
      return false;
    } catch (e) {
      errorMessage.value = 'Google sign-in failed. Please try again.';
      debugPrint(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Firebase error mapper ──────────────────────────────────────────────────

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
