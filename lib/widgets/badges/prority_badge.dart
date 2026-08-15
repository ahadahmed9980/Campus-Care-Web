import 'package:flutter/material.dart';

class ProrityBadge extends StatelessWidget {
  final String priority;
  ProrityBadge({required this.priority, super.key});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = switch (priority.trim().toLowerCase()) {
      'high' => (
        const Color(0xFFFFEBEE),
        const Color(0xFFE53935),
      ), // Light Red bg, Dark Red text
      'medium' => (
        const Color(0xFFFFF8E1),
        const Color(0xFFFFA000),
      ), // Light Amber bg, Dark Amber text
      'low' => (
        const Color(0xFFE0F2F1),
        const Color(0xFF00897B),
      ), // Light Teal/Green bg, Dark Teal text
      _ => (const Color(0xFFF5F5F5), const Color(0xFF757575)), // Default Grey
    };

    return Container(
      width: 75,
      height: 28,
      padding: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        priority,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
