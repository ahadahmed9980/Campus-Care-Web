import 'package:flutter/material.dart';
import 'appcolors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.lightCard,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.lightText,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightText,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.darkCard,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.darkText,
      ),
      bodyMedium: TextStyle(
        color: AppColors.darkText,
      ),
    ),
  );
}