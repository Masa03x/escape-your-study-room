import 'package:flutter/material.dart';

abstract final class AppColors {
  // Version B — warm, light study-break theme
  static const background = Color(0xFFFFF8EC);
  static const surface = Color(0xFFFFFCF6);
  static const card = Color(0xFFFFFFFF);
  static const elevated = Color(0xFFE8F5F1);
  static const border = Color(0xFFE7DDCF);

  static const teal = Color(0xFF2A9D8F);
  static const tealDark = Color(0xFF1F756B);
  static const mint = Color(0xFFBFE3DB);

  static const coral = Color(0xFFE76F51);
  static const coralLight = Color(0xFFF4A28C);

  static const yellow = Color(0xFFF4C95D);
  static const yellowSoft = Color(0xFFFFE9A9);

  static const green = Color(0xFF5FAF7B);
  static const greenLight = Color(0xFFDDF3E5);

  static const red = Color(0xFFD95D54);

  static const text = Color(0xFF2D2A26);
  static const textSoft = Color(0xFF5F5A52);
  static const textMuted = Color(0xFF928A80);
}

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w900,
        ),
        headlineMedium: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSoft,
          fontWeight: FontWeight.w500,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tealDark,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}