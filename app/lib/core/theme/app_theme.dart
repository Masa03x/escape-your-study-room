import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF101415);
  static const surface = Color(0xFF171C1E);
  static const card = Color(0xFF202628);

  static const border = Color(0xFF394245);

  static const lime = Color(0xFFB7FF3C);
  static const cyan = Color(0xFF27E1FF);

  static const yellow = Color(0xFFFFD23F);
  static const red = Color(0xFFFF5C5C);

  static const text = Color(0xFFF5F7F6);
  static const textSoft = Color(0xFFC4CDCA);
  static const textMuted = Color(0xFF7D8985);

  static const black = Color(0xFF090C0D);
}

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.lime,
        secondary: AppColors.cyan,
        surface: AppColors.surface,
        error: AppColors.red,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.black,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
