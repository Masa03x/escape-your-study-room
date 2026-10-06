import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const background = Color(0xFF06051A);
  static const surface = Color(0xFF0D0B2A);
  static const mid = Color(0xFF141240);
  static const card = Color(0xFF1C1A4E);
  static const elevated = Color(0xFF252364);

  static const border = Color(0xFF2A275F);
  static const borderLight = Color(0xFF3D3890);

  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFA78BFA);
  static const purpleDark = Color(0xFF5B21B6);
  static const purpleSoft = Color(0xFF6D28D9);

  static const green = Color(0xFF22C55E);
  static const greenLight = Color(0xFF4ADE80);

  static const orange = Color(0xFFF59E0B);
  static const orangeLight = Color(0xFFFCD34D);

  static const red = Color(0xFFEF4444);
  static const redDark = Color(0xFF991B1B);

  static const blue = Color(0xFF1D4ED8);
  static const blueDark = Color(0xFF1E3A8A);

  static const text = Color(0xFFEEEEFF);
  static const textSoft = Color(0xFFC4B5FD);
  static const textMuted = Color(0xFF7870A8);
}

abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purple,
        secondary: AppColors.green,
        surface: AppColors.surface,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: GoogleFonts.nunito().fontFamily,
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static TextStyle fredoka({
    double? fontSize,
    Color color = AppColors.text,
    FontWeight fontWeight = FontWeight.w600,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.fredoka(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle nunito({
    double? fontSize,
    Color color = AppColors.text,
    FontWeight fontWeight = FontWeight.w600,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }
}
