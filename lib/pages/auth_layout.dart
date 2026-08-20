import 'package:customer_care_webapp/pages/forgot_password_page.dart';
import 'package:customer_care_webapp/pages/login_page.dart';
import 'package:customer_care_webapp/utils/responseive.dart';
import 'package:customer_care_webapp/widgets/auth_left_panel.dart';
import 'package:customer_care_webapp/widgets/theme_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;

  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isCompact = !Responsive.isDesktopScreen(context) &&
        !Responsive.isLargeDesktopScreen(context);
    final isForgot =
        GoRouterState.of(context).matchedLocation == '/forgot-password';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final formCard = Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 520),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                ...previousChildren,
                ?currentChild,
              ],
            );
          },
          transitionBuilder: (widget, animation) {
            final isForgotChild = widget.key == const ValueKey('forgot');
            final begin = isForgotChild
                ? const Offset(-1.0, 0.0)
                : const Offset(1.0, 0.0);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: begin,
                  end: Offset.zero,
                ).animate(animation),
                child: widget,
              ),
            );
          },
          child: isForgot
              ? const ForgotPasswordPage(key: ValueKey('forgot'))
              : const LoginPage(key: ValueKey('login')),
        ),
      ),
    );

    final leftPanel = AuthLeftPanel(
      compact: isCompact,
      heading: isForgot ? 'Reset Password' : 'Welcome Back!',
      subtitle: isForgot
          ? 'Enter your email and we will send a link to reset your password.'
          : 'Manage campus requests, users, and reports from one secure dashboard.',
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Offstage(child: child),
          isCompact
              ? SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        leftPanel,
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                          child: formCard,
                        ),
                      ],
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(flex: 5, child: leftPanel),
                    Expanded(
                      flex: 6,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 32,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: formCard,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          Positioned(
            top: isCompact ? 12 : 20,
            right: isCompact ? 12 : 24,
            child: const ThemeToggleSwitch(),
          ),
        ],
      ),
    );
  }
}
