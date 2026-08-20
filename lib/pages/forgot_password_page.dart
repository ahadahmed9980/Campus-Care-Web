import 'package:customer_care_webapp/controller/forgot_password_controller.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  const ForgotPasswordPage({super.key});

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hint,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF7F9FA);
    final border = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE6EAEF);

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required bool success,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? AppColors.primary : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!(controller.formKey.currentState?.validate() ?? false)) return;

    controller.isLoading.value = true;
    try {
      final message = await controller.sendPasswordResetEmail();
      if (!context.mounted) return;
      _showSnackBar(context, message: message, success: true);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      _showSnackBar(
        context,
        message: controller.mapAuthError(e),
        success: false,
      );
    } catch (_) {
      if (!context.mounted) return;
      _showSnackBar(
        context,
        message: 'Unable to send reset email. Please try again.',
        success: false,
      );
    } finally {
      controller.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: controller.formKey,
      child: Column(
        key: const ValueKey('forgot-form'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                color: AppColors.adaptivePrimary(context),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Forgot Password',
            style: textTheme.headlineLarge?.copyWith(
              fontSize: 28,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter the email associated with your admin account.',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: AppColors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Email',
            style: textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: controller.validateEmail,
            onFieldSubmitted: (_) => _handleSubmit(context),
            decoration: _inputDecoration(
              context: context,
              hint: 'admin@da.edu.pk',
              icon: Icons.mail_outline_rounded,
            ),
          ),
          const SizedBox(height: 28),
          Obx(
            () => SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => _handleSubmit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Send Reset Link',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(
              'Back to Sign In',
              style: TextStyle(
                color: AppColors.adaptivePrimary(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
