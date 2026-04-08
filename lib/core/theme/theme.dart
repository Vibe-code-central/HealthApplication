import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RequiemColors {
  static const Color primaryBackground = Color(0xFF060606);
  static const Color secondarySurface = Color(0xFF0F0F0F);
  static const Color tertiarySurface = Color(0xFF161616);
  static const Color border = Color(0xFF232323);

  static const Color bsaaRed = Color(0xFFC0392B);
  static const Color ember = Color(0xFFE8712A);
  static const Color gold = Color(0xFFC9A84C);
  static const Color operative = Color(0xFF27AE60);
  static const Color intelBlue = Color(0xFF4A9EFF);
  static const Color shadow = Color(0xFF8E44AD);
  static const Color wesker = Color(0xFF8B0000);

  static const Color textPrimary = Color(0xFFE2E2E2);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF444444);
}

class RequiemTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: RequiemColors.primaryBackground,
      colorScheme: const ColorScheme.dark(
        primary: RequiemColors.bsaaRed,
        surface: RequiemColors.secondarySurface,
        onSurface: RequiemColors.textPrimary,
        error: RequiemColors.ember,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: RequiemColors.secondarySurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.bebasNeue(
          color: RequiemColors.textPrimary,
          fontSize: 24,
          letterSpacing: 2.0,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.bebasNeue(color: RequiemColors.textPrimary, fontSize: 40, letterSpacing: 2.0),
        displayMedium: GoogleFonts.bebasNeue(color: RequiemColors.textPrimary, fontSize: 32, letterSpacing: 1.5),
        displaySmall: GoogleFonts.bebasNeue(color: RequiemColors.textPrimary, fontSize: 24, letterSpacing: 1.2),
        headlineMedium: GoogleFonts.bebasNeue(color: RequiemColors.textPrimary, fontSize: 20, letterSpacing: 1.0),
        bodyLarge: GoogleFonts.barlow(color: RequiemColors.textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.barlow(color: RequiemColors.textPrimary, fontSize: 14),
        labelLarge: GoogleFonts.barlowCondensed(color: RequiemColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
        labelSmall: GoogleFonts.barlowCondensed(color: RequiemColors.textSecondary, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RequiemColors.bsaaRed,
          foregroundColor: RequiemColors.textPrimary,
          textStyle: GoogleFonts.barlowCondensed(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      cardTheme: CardTheme(
        color: RequiemColors.secondarySurface,
        elevation: 4,
        shadowColor: RequiemColors.bsaaRed.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: RequiemColors.border, width: 1),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: RequiemColors.primaryBackground,
        selectedItemColor: RequiemColors.bsaaRed,
        unselectedItemColor: RequiemColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.barlowCondensed(fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.barlowCondensed(),
      ),
    );
  }
}
