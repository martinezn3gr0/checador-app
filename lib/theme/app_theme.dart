import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design tokens for the futuristic Checador Express UI.
class AppColors {
  AppColors._();

  // Deep space background stack
  static const Color bg0 = Color(0xFF05070F);
  static const Color bg1 = Color(0xFF0A0E1C);
  static const Color bg2 = Color(0xFF0E1430);

  // Neon employee accent (cyan -> blue -> violet)
  static const Color cyan = Color(0xFF22E1FF);
  static const Color blue = Color(0xFF4C6FFF);
  static const Color violet = Color(0xFF9A5CFF);

  // Admin accent (amber -> orange)
  static const Color amber = Color(0xFFFFCB2D);
  static const Color orange = Color(0xFFFF8A34);

  // Semantic
  static const Color green = Color(0xFF2FE6A8);
  static const Color pink = Color(0xFFFF4D8D);
  static const Color purple = Color(0xFF9A5CFF);

  static const Color textPrimary = Color(0xFFF2F6FF);
  static const Color textMuted = Color(0xFF8A93B2);

  // Glass surfaces
  static Color glass = Colors.white.withOpacity(0.055);
  static Color glassStrong = Colors.white.withOpacity(0.09);
  static Color glassBorder = Colors.white.withOpacity(0.12);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient neon = LinearGradient(
    colors: [AppColors.cyan, AppColors.blue, AppColors.violet],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient admin = LinearGradient(
    colors: [AppColors.amber, AppColors.orange],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient card = LinearGradient(
    colors: [Color(0x14FFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg1,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.cyan,
        secondary: AppColors.violet,
        surface: AppColors.bg2,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.bg2,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.glassBorder),
        ),
      ),
    );
  }

  /// Orbitron gives the brand/headings a techy, futuristic feel.
  static TextStyle display(double size, {Color? color, FontWeight weight = FontWeight.w700}) {
    return GoogleFonts.orbitron(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      letterSpacing: 1.2,
    );
  }
}
