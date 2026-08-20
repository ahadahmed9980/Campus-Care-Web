import 'package:customer_care_webapp/controller/login_controller.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF7F9FA);
    final border = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE6EAEF);

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
      suffixIcon: suffix,
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

  Future<void> _handleSignIn(BuildContext context) async {
    if (!(controller.formKey.currentState?.validate() ?? false)) return;
    final success = await controller.signIn();
    if (success && context.mounted) {
      context.go('/dashboard');
    }
  }

  Future<void> _handleGoogle(BuildContext context) async {
    final success = await controller.signInWithGoogle();
    if (success && context.mounted) {
      context.go('/dashboard');
    }
  }

  void _openForgotPassword(BuildContext context) {
    final email = controller.emailController.text.trim();
    final location = email.isEmpty
        ? '/forgot-password'
        : '/forgot-password?email=${Uri.encodeComponent(email)}';
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Form(
      key: controller.formKey,
      child: Column(
        key: const ValueKey('login-form'),
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
                Icons.lock_outline_rounded,
                color: AppColors.adaptivePrimary(context),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Admin Login',
            style: textTheme.headlineLarge?.copyWith(
              fontSize: 28,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your credentials to continue.',
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
            textInputAction: TextInputAction.next,
            validator: controller.validateEmail,
            decoration: _inputDecoration(
              context: context,
              hint: 'admin@da.edu.pk',
              icon: Icons.mail_outline_rounded,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Password',
            style: textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSignIn(context),
              validator: controller.validatePassword,
                decoration: _inputDecoration(
                  context: context,
                  hint: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: controller.togglePasswordVisibility,
                  icon: Icon(
                    controller.obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Obx(
                () => Checkbox(
                  value: controller.rememberMe.value,
                  onChanged: controller.toggleRememberMe,
                  activeColor: AppColors.adaptivePrimary(context),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              Text(
                'Remember me',
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _openForgotPassword(context),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.adaptivePrimary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          Obx(() {
            if (controller.errorMessage.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            );
          }),
          const SizedBox(height: 8),
          Obx(
            () => SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => _handleSignIn(context),
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
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          Obx(
            () => SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: controller.isLoading.value
                    ? null
                    : () => _handleGoogle(context),
                icon: Icon(
                  Icons.g_mobiledata_rounded,
                  size: 28,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                label: Text(
                  'Sign in with Google',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE6EAEF),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
