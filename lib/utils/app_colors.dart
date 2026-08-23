import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF018D5C);
  static const Color blue = Color(0xFF126FC5);
  static const Color lightGreen = Color(0xFFE3F2EA);
  static const Color orange = Color(0xFFFD9B03);
  static const Color red = Colors.red;

  static const Color lightBackground = Color(0xFFF7F9FA);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightCard = Colors.white;
  static const Color grey = Color(0xFFA1A7B3);

  static const Color darkBackground = Color(0xFF000000);
  static const Color darkText = Colors.white;
  static const Color darkCard = Color(0xFF121212);

  /// Brighter primary for dark surfaces so accents stay readable.
  static Color adaptivePrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF54CFC1) : primary;
  }
}
