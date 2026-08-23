import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────
// Colours used only inside the auth left panel
// ─────────────────────────────────────────────────────────────
class _PanelColors {
  // light-mode (green gradient)
  static const Color lightGradStart = Color(0xFF013825);
  static const Color lightGradMid   = Color(0xFF016B46);
  static const Color lightGradEnd   = AppColors.primary; // 018D5C
  static const Color lightText      = Colors.white;
  static const Color lightAccent    = Color(0xFF7DFFC8); // "Care" teal
  static const Color lightMuted     = Color(0xCCFFFFFF); // white 80%
  static const Color lightIconBg    = Color(0x1FFFFFFF); // white 12%

  // dark-mode (near-black)
  static const Color darkBg         = Color(0xFF121212);
  static const Color darkBgEnd      = Color(0xFF1A1F1C); // very subtle warmth
  static const Color darkAccent     = Color(0xFF54CFC1); // pastel teal
  static const Color darkText       = Color(0xFFF0FFFE); // near-white, warm
  static const Color darkMuted      = Color(0xFF8BBFB9); // muted teal
  static const Color darkIconBg     = Color(0x2654CFC1); // accent 15%
}

class AuthLeftPanel extends StatelessWidget {
  final bool compact;
  final String heading;
  final String subtitle;

  const AuthLeftPanel({
    super.key,
    required this.compact,
    this.heading = 'Welcome Back!',
    this.subtitle =
        'Manage campus requests, users, and reports from one secure dashboard.',
  });

  @override
  Widget build(BuildContext context) {
    // Listen to dark-mode reactively so the panel repaints when toggled.
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final isDark = controller.isDarkMode.value;

      final textColor    = isDark ? _PanelColors.darkText   : _PanelColors.lightText;
      final accentColor  = isDark ? _PanelColors.darkAccent : _PanelColors.lightAccent;
      final mutedColor   = isDark ? _PanelColors.darkMuted  : _PanelColors.lightMuted;
      final iconBgColor  = isDark ? _PanelColors.darkIconBg : _PanelColors.lightIconBg;
      final iconColor    = isDark ? _PanelColors.darkAccent : Colors.white;

      final Decoration backgroundDecoration = isDark
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_PanelColors.darkBg, _PanelColors.darkBgEnd],
              ),
            )
          : const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _PanelColors.lightGradStart,
                  _PanelColors.lightGradMid,
                  _PanelColors.lightGradEnd,
                ],
              ),
            );

      // Decorative circles – more visible in light, subtle in dark
      final circleAlpha = isDark ? 0.04 : 0.06;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 28 : 56,
          vertical: compact ? 36 : 64,
        ),
        decoration: backgroundDecoration,
        child: Stack(
          children: [
            // top-right decorative circle
            Positioned(
              right: -40,
              top: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: circleAlpha),
                ),
              ),
            ),
            // bottom-left decorative circle
            Positioned(
              left: -30,
              bottom: compact ? 0 : 40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: circleAlpha * 0.8),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  compact ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                // ── Logo row ──────────────────────────────────────────
                Row(
                  children: [
                    _LogoImage(
                      size: compact ? 44 : 56,
                      isDark: isDark,
                      accentColor: accentColor,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 350),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              child: const Text('Campus'),
                            ),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 350),
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              child: const Text('Care'),
                            ),
                          ],
                        ),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 350),
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 13,
                          ),
                          child: const Text('Admin Portal'),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: compact ? 28 : 48),

                // ── Heading ───────────────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-0.12, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 350),
                    style: TextStyle(
                      color: textColor,
                      fontSize: compact ? 28 : 36,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    child: Text(heading, key: ValueKey(heading)),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Subtitle ──────────────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 350),
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: compact ? 14 : 16,
                      height: 1.5,
                    ),
                    child: Text(subtitle, key: ValueKey(subtitle)),
                  ),
                ),

                SizedBox(height: compact ? 24 : 40),

                // ── Feature points ────────────────────────────────────
                _FeaturePoint(
                  icon: Icons.insights_outlined,
                  title: 'Real-time Overview',
                  subtitle:
                      'Track requests and campus activity as they happen.',
                  textColor: textColor,
                  iconColor: iconColor,
                  iconBg: iconBgColor,
                  descColor: mutedColor,
                ),
                const SizedBox(height: 16),
                _FeaturePoint(
                  icon: Icons.tune_rounded,
                  title: 'Smart Management',
                  subtitle:
                      'Assign, prioritize, and resolve issues efficiently.',
                  textColor: textColor,
                  iconColor: iconColor,
                  iconBg: iconBgColor,
                  descColor: mutedColor,
                ),
                const SizedBox(height: 16),
                _FeaturePoint(
                  icon: Icons.notifications_active_outlined,
                  title: 'Stay Updated',
                  subtitle: 'Get alerts so nothing important is missed.',
                  textColor: textColor,
                  iconColor: iconColor,
                  iconBg: iconBgColor,
                  descColor: mutedColor,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
// Logo image with dark-mode fallback tinting
// ─────────────────────────────────────────────────────────────
class _LogoImage extends StatelessWidget {
  final double size;
  final bool isDark;
  final Color accentColor;

  const _LogoImage({
    required this.size,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      // Apply a tint in dark mode so the logo stays bright
      color: isDark ? accentColor : null,
      colorBlendMode: isDark ? BlendMode.srcIn : null,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? _PanelColors.darkIconBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.school_rounded,
          color: isDark ? accentColor : AppColors.primary,
          size: size * 0.55,
        ),
      ),
    );

    // In dark mode add a subtle rounded container so the logo
    // pops against the near-black background
    if (isDark) {
      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _PanelColors.darkIconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: image,
      );
    }
    return image;
  }
}

// ─────────────────────────────────────────────────────────────
// Feature bullet point – colours passed in from parent
// ─────────────────────────────────────────────────────────────
class _FeaturePoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color textColor;
  final Color iconColor;
  final Color iconBg;
  final Color descColor;

  const _FeaturePoint({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.iconColor,
    required this.iconBg,
    required this.descColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 350),
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(title),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 350),
                style: TextStyle(color: descColor, fontSize: 13, height: 1.4),
                child: Text(subtitle),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
