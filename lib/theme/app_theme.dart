import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Alight Motion inspired dark palette
  static const Color bg = Color(0xFF13111F);
  static const Color surface = Color(0xFF1C1A2E);
  static const Color surfaceElevated = Color(0xFF252340);
  static const Color surfaceHigh = Color(0xFF2E2B50);
  static const Color border = Color(0xFF302D55);
  static const Color borderLight = Color(0xFF3D3A6A);

  static const Color accent = Color(0xFF7C3AED); // Alight Motion purple
  static const Color accentLight = Color(0xFF9F67FF);
  static const Color accentTeal = Color(0xFF06B6D4);
  static const Color accentGlow = Color(0xFFBD93F9);

  static const Color textPrimary = Color(0xFFECE8FF);
  static const Color textSecondary = Color(0xFF9B92C8);
  static const Color textMuted = Color(0xFF5C5490);

  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  static const Color timeline = Color(0xFF0F0D1A);
  static const Color timelineTrack = Color(0xFF1A1830);
  static const Color keyframe = Color(0xFFFFD700);
  static const Color playhead = Color(0xFF7C3AED);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentTeal,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          labelSmall: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 0.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          elevation: 0,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.accentLight,
        overlayColor: AppColors.accent.withOpacity(0.2),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}
