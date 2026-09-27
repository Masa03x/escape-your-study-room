import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF06051A);
  static const surface = Color(0xFF0D0B2A);
  static const card = Color(0xFF1C1A4E);
  static const elevated = Color(0xFF252364);
  static const border = Color(0xFF2A275F);

  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFA78BFA);
  static const green = Color(0xFF22C55E);
  static const greenLight = Color(0xFF4ADE80);
  static const orange = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);

  static const text = Color(0xFFEEEEFF);
  static const textSoft = Color(0xFFC4B5FD);
  static const textMuted = Color(0xFF8A83B6);
}

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.purple,
        brightness: Brightness.dark,
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
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
