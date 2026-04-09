import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color Palette ──────────────────────────────────────────────────────────

class RequiemColors {
  static const Color primaryBackground = Color(0xFF060606);
  static const Color secondarySurface = Color(0xFF0C0C0C);
  static const Color tertiarySurface = Color(0xFF141414);
  static const Color border = Color(0xFF1E1E1E);
  static const Color borderBright = Color(0xFF2A2A2A);

  static const Color bsaaRed = Color(0xFFC0392B);
  static const Color ember = Color(0xFFE8712A);
  static const Color gold = Color(0xFFC9A84C);
  static const Color operative = Color(0xFF27AE60);
  static const Color intelBlue = Color(0xFF4A9EFF);
  static const Color shadow = Color(0xFF8E44AD);
  static const Color wesker = Color(0xFF8B0000);

  static const Color textPrimary = Color(0xFFE2E2E2);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFF333333);
}

// ── Shared RE Widget Primitives ────────────────────────────────────────────

/// A "dossier-style" section header — horizontal red line, label, corner tick marks.
class ReDividerHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const ReDividerHeader({
    super.key,
    required this.label,
    this.color = RequiemColors.bsaaRed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          Container(width: 3, height: 16, color: color),
          const SizedBox(width: 8),
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.barlowCondensed(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A sharp-cornered container that looks like a classified file panel.
class RePanel extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final EdgeInsets padding;
  final bool showCornerMarks;

  const RePanel({
    super.key,
    required this.child,
    this.borderColor = RequiemColors.borderBright,
    this.padding = const EdgeInsets.all(14),
    this.showCornerMarks = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: RequiemColors.secondarySurface,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: child,
        ),
        // Corner tick marks (top-left)
        if (showCornerMarks) ...[
          Positioned(top: 0, left: 0, child: _corner()),
          Positioned(
              top: 0,
              right: 0,
              child: Transform.rotate(angle: 1.5708, child: _corner())),
          Positioned(
              bottom: 0,
              left: 0,
              child: Transform.rotate(angle: -1.5708, child: _corner())),
          Positioned(
              bottom: 0,
              right: 0,
              child: Transform.rotate(angle: 3.14159, child: _corner())),
        ],
      ],
    );
  }

  Widget _corner() => SizedBox(
        width: 10,
        height: 10,
        child: CustomPaint(painter: _CornerPainter(borderColor)),
      );
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// A biohazard-style XP status bar.
class ReStatusBar extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final Color color;
  final double height;

  const ReStatusBar({
    super.key,
    required this.value,
    this.color = RequiemColors.bsaaRed,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final filledWidth = constraints.maxWidth * value.clamp(0.0, 1.0);
      return SizedBox(
        height: height,
        child: Stack(
          children: [
            // Background track with segment lines
            Container(
              width: double.infinity,
              height: height,
              color: RequiemColors.tertiarySurface,
            ),
            // Fill
            Container(
              width: filledWidth,
              height: height,
              color: color,
            ),
            // Scan line overlay
            Positioned.fill(
              child: Row(
                children: List.generate(
                  10,
                  (i) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Theme ──────────────────────────────────────────────────────────────────

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
        backgroundColor: RequiemColors.primaryBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.bebasNeue(
          color: RequiemColors.textPrimary,
          fontSize: 22,
          letterSpacing: 3.0,
        ),
        iconTheme: const IconThemeData(color: RequiemColors.textPrimary),
        actionsIconTheme: const IconThemeData(color: RequiemColors.textSecondary),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.bebasNeue(
            color: RequiemColors.textPrimary, fontSize: 40, letterSpacing: 3),
        displayMedium: GoogleFonts.bebasNeue(
            color: RequiemColors.textPrimary, fontSize: 32, letterSpacing: 2),
        displaySmall: GoogleFonts.bebasNeue(
            color: RequiemColors.textPrimary, fontSize: 24, letterSpacing: 1.5),
        headlineMedium: GoogleFonts.bebasNeue(
            color: RequiemColors.textPrimary, fontSize: 20, letterSpacing: 1.5),
        bodyLarge: GoogleFonts.barlow(
            color: RequiemColors.textPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.barlow(
            color: RequiemColors.textSecondary, fontSize: 13),
        labelLarge: GoogleFonts.barlowCondensed(
            color: RequiemColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5),
        labelSmall: GoogleFonts.barlowCondensed(
            color: RequiemColors.textSecondary, fontSize: 11, letterSpacing: 1),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RequiemColors.bsaaRed,
          foregroundColor: RequiemColors.textPrimary,
          elevation: 0,
          textStyle: GoogleFonts.barlowCondensed(
              fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          side: const BorderSide(color: RequiemColors.bsaaRed, width: 1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: RequiemColors.bsaaRed,
          textStyle: GoogleFonts.barlowCondensed(
              fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      cardTheme: const CardTheme(
        color: RequiemColors.secondarySurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RequiemColors.tertiarySurface,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: RequiemColors.borderBright),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: RequiemColors.borderBright),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: RequiemColors.bsaaRed, width: 1.5),
        ),
        labelStyle: GoogleFonts.barlowCondensed(
            color: RequiemColors.textSecondary, letterSpacing: 1.5),
        hintStyle: GoogleFonts.barlow(color: RequiemColors.textMuted, fontSize: 13),
      ),
      dividerTheme: const DividerThemeData(
        color: RequiemColors.borderBright,
        thickness: 1,
        space: 0,
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: RequiemColors.secondarySurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: RequiemColors.secondarySurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: RequiemColors.primaryBackground,
        selectedItemColor: RequiemColors.bsaaRed,
        unselectedItemColor: RequiemColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.barlowCondensed(
            fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5),
        unselectedLabelStyle:
            GoogleFonts.barlowCondensed(fontSize: 10, letterSpacing: 1.5),
      ),
    );
  }
}
