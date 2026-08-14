import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primary,
    cardColor: AppColors.lightCard,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.lightCard,
      onSurface: AppColors.lightText,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        headlineLarge: TextStyle(
          fontSize: 25.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.lightText,
        ),
        headlineMedium: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText,
        ),
        bodyLarge: TextStyle(
          fontSize: 18.sp,
          height: 1.5,
          color: AppColors.lightText,
        ),
        bodyMedium: TextStyle(
          fontSize: 10.sp,
          height: 1.2,
          color: AppColors.grey,
        ),
        labelLarge: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
          color: AppColors.lightText,
        ),
        labelSmall: TextStyle(
          fontSize: 8.sp,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.8,
          color: AppColors.grey,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.primary,
    cardColor: AppColors.darkCard,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkText,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      TextTheme(
        headlineLarge: TextStyle(
          fontSize: 25.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
        headlineMedium: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 18.sp,
          height: 1.5,
          color: AppColors.darkText,
        ),
        bodyMedium: TextStyle(
          fontSize: 12.sp,
          height: 1.2,
          color: AppColors.grey,
        ),
        labelLarge: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
          color: AppColors.lightText,
        ),
        labelSmall: TextStyle(
          fontSize: 8.sp,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.8,
          color: AppColors.grey,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
