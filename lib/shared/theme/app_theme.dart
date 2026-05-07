import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand palette PRO ────────────────────────────

  // GOLD (primary)
  static const _lightPrimary      = Color(0xFFAB873E);
  static const _lightPrimaryDark  = Color(0xFF8C6B2F);
  static const _lightPrimarySoft  = Color(0xFFE6D3A3);

  // DARK (text)
  static const _lightDark         = Color.fromARGB(255, 46, 46, 46);
  static const _lightDarkSoft     = Color(0xFF6B6B6B);

  // BACKGROUND
  static const _lightScaffold     = Color(0xFFF5F5F5);
  static const _lightSurface      = Colors.white;

  // UI
  static const _lightBorder       = Color(0xFFE0E0E0);
  static const _lightFill         = Color(0xFFFAFAFA);
  static const _lightHint         = Color(0xFF9E9E9E);
  static const _lightIconColor    = Color(0xFF7A7A7A);
  static const _lightChipBorder   = Color(0xFFD6D6D6);
  static const _lightSubtleText   = Color(0xFF757575);

  // ── DARK THEME ───────────────────────────────────

  static const _darkPrimary    = Color(0xFFAB873E); // GOLD
  static const _darkSecondary  = Color(0xFF494949);

  static const _darkScaffold   = Color(0xFF1E1E1E);
  static const _darkSurface    = Color(0xFF2A2A2A);

  static const _darkIconColor  = Color(0xFFB0B0B0);
  static const _darkBorder     = Color(0xFF3A3A3A);
  static const _darkFill       = Color(0xFF2F2F2F);
  static const _darkHint       = Color(0xFF9E9E9E);
  static const _darkSubtleText = Color(0xFFBDBDBD);

  // ── Exposed (si besoin ailleurs) ─────────────────
  static const lightPrimary   = _lightPrimary;
  static const lightSecondary = _lightDark;

  // ── LIGHT THEME ─────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Georgia',
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightDark,
      surface: _lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _lightDark,
    ),

    scaffoldBackgroundColor: _lightScaffold,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
          fontSize: 14.5, fontWeight: FontWeight.w500, color: _lightDark),
      labelMedium: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: _lightDark),
      bodySmall: TextStyle(
          fontSize: 12.5, height: 1.5, color: _lightSubtleText),
      labelSmall: TextStyle(fontSize: 11, color: _lightHint),

      titleMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: _lightDark),

      labelLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _lightPrimary), // GOLD

      titleLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: _lightDark),
    ),

    iconTheme: const IconThemeData(
      color: _lightIconColor,
      size: 20,
    ),

    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightFill,
      hintStyle: const TextStyle(
        color: _lightHint,
        fontSize: 13.5,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightBorder),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightBorder),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: _lightPrimary, width: 1.8), // GOLD
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFCCCCCC),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightDark,
        side: const BorderSide(color: _lightPrimary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? _lightPrimary
              : Colors.transparent),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: _lightDarkSoft, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );

  // ── DARK THEME ─────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Georgia',
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkSecondary,
      surface: _darkSurface,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),

    scaffoldBackgroundColor: _darkScaffold,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
          fontSize: 14.5, fontWeight: FontWeight.w500, color: Colors.white),
      labelMedium: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
      bodySmall: TextStyle(
          fontSize: 12.5, height: 1.5, color: _darkSubtleText),
      labelSmall: TextStyle(fontSize: 11, color: _darkHint),

      titleMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),

      labelLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _darkPrimary),

      titleLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white),
    ),

    iconTheme: const IconThemeData(
      color: _darkIconColor,
      size: 20,
    ),

    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkFill,
      hintStyle: const TextStyle(
        color: _darkHint,
        fontSize: 13.5,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkBorder),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: _darkPrimary, width: 1.8),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.black,
        disabledBackgroundColor: const Color(0xFF444444),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: _darkPrimary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? _darkPrimary
              : Colors.transparent),
      checkColor: WidgetStateProperty.all(Colors.black),
      side: const BorderSide(color: _darkIconColor, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}