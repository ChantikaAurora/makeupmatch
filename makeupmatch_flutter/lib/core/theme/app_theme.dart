import 'package:flutter/material.dart';

class AppTheme {

  // Primary — Rose Mauve
  static const Color primary = Color(0xFFC97B84);
  static const Color primaryDark = Color(0xFFA85F6B);
  static const Color primaryLight = Color(0xFFE3AEB4);

  // Secondary — Soft Lavender (dipakai untuk background ikon, chip, dll)
  static const Color secondary = Color(0xFFE8DFF5);

  // Accent — Gold (dipakai tipis, untuk highlight/aksen kecil saja)
  static const Color accent = Color(0xFFD4AF7A);

  // Blush — aksen lembut tambahan (gradient, badge, empty state bg)
  static const Color blush = Color(0xFFF7E4E4);

  // Background & Surface
  static const Color background = Color(0xFFFFFBF7); // Cream
  static const Color surface = Color(0xFFFFFFFF);

  // Text — Deep Plum family
  static const Color textPrimary = Color(0xFF6B4357);
  static const Color textSecondary = Color(0xFF9B7B8A);
  static const Color textHint = Color(0xFFC9AFB8);

  // Status
  static const Color error = Color(0xFFD9636B);
  static const Color success = Color(0xFF8FBFA0);

  // Divider — blush-tinted, bukan abu-abu netral
  static const Color divider = Color(0xFFF0E4E6);

  // Gradient signature — dipakai di banner/hero
  static const List<Color> primaryGradient = [primary, primaryDark];
  static const List<Color> goldGradient = [accent, Color(0xFFE8C99A)];
  static const List<Color> lavenderGradient = [secondary, primaryLight];

  // Gradient dipakai untuk banner/carousel
  static const List<Color> heroGradient = [
    Color(0xFFF2A6C1),
    Color(0xFFD1698D),
  ];

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: surface,
          background: background,
          error: error,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: error),
          ),
          labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
          hintStyle: const TextStyle(color: textHint, fontSize: 14),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: divider),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: textHint,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}