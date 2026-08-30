import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/widgets/theme_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.adaptivePrimary(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            height: 70,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: theme.cardColor,
            child: Row(
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const ThemeToggleSwitch(compact: true),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.28 : 0.05,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                        child: const Text('Appearance'),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Switch between light and dark mode. Labels and section headers adapt for contrast.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: AppColors.grey,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOutCubic,
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: accent,
                                  ),
                                  child: const Text('Dark mode'),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isDark
                                      ? 'On — using a darker canvas and pastel accents.'
                                      : 'Off — using the light Campus Care theme.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const ThemeToggleSwitch(compact: true),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 450.ms, curve: Curves.easeOutCubic).slideY(begin: 0.05, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
