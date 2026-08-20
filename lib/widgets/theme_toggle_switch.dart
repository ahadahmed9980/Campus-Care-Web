import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeToggleSwitch extends StatelessWidget {
  final bool compact;

  const ThemeToggleSwitch({
    super.key,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(
      () => _AppearanceToggle(
        isDark: controller.isDarkMode.value,
        onToggle: controller.toggleTheme,
        compact: compact,
      ),
    );
  }
}

class _AppearanceToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;
  final bool compact;

  const _AppearanceToggle({
    required this.isDark,
    required this.onToggle,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final trackWidth = compact ? 36.0 : 52.0;
    final trackHeight = compact ? 20.0 : 28.0;
    final thumbSize = compact ? 14.0 : 22.0;
    final iconSize = compact ? 14.0 : 22.0;
    final gap = compact ? 6.0 : 12.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onToggle,
        child: Semantics(
          button: true,
          toggled: isDark,
          label: 'Toggle dark mode',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 14,
              vertical: compact ? 4 : 8,
            ),
            decoration: BoxDecoration(
              color: isDarkTheme ? const Color(0xFF1C1C1C) : Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDarkTheme ? 0.35 : 0.08,
                  ),
                  blurRadius: compact ? 8 : 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  size: iconSize,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
                SizedBox(width: gap),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  width: trackWidth,
                  height: trackHeight,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB7D9C9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    alignment:
                        isDark ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: gap),
                Icon(
                  Icons.nightlight_round,
                  size: iconSize,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
