import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController({this.initialEmail});

  final String? initialEmail;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (initialEmail != null && initialEmail!.trim().isNotEmpty) {
      emailController.text = initialEmail!.trim();
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(email)) return 'Enter a valid email address';
    return null;
  }

  Future<String> sendPasswordResetEmail() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: emailController.text.trim(),
    );
    return 'Password reset email sent. Check your inbox.';
  }

  String mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'missing-email':
        return 'Email is required.';
      case 'invalid-continue-uri':
      case 'unauthorized-continue-uri':
        return 'Password reset could not be completed. Try again later.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Unable to send reset email.';
    }
  }
}
