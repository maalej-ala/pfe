// app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand palette ────────────────────────────────────────────
  // Light
  static const _lightPrimary    = Color(0xFF0A2342);
  static const _lightSecondary  = Color(0xFFC9A84C);
  static const _lightDarkBlue   = Color(0xFF1A3A5C);
  static const _lightCardBg     = Color(0xFF122D4E);
  static const _lightScaffold   = Color(0xFFF5F3EE);
  static const _lightSurface    = Colors.white;
  static const _lightIconColor  = Color(0xFF8899AA);
  static const _lightBorder     = Color(0xFFE5E0D5);
  static const _lightFill       = Color(0xFFF9F8F5);
  static const _lightHint       = Color(0xFFAAAAAA);
  static const _lightChipBorder = Color(0xFFDDD8CC);
  static const _lightSubtleText = Color(0xFF555555);

  // Dark
  static const _darkPrimary    = Color(0xFFE8EEF7);   // light text on dark
  static const _darkSecondary  = Color(0xFFD4A853);   // gold, slightly brighter
  static const _darkScaffold   = Color(0xFF0D1B2A);   // deep navy background
  static const _darkSurface    = Color(0xFF142233);   // card surface
  static const _darkIconColor  = Color(0xFF7A90A8);
  static const _darkBorder     = Color(0xFF243447);
  static const _darkFill       = Color(0xFF1A2E42);
  static const _darkHint       = Color(0xFF5A7080);
  static const _darkChipBorder = Color(0xFF2A3E52);
  static const _darkSubtleText = Color(0xFFAABBCC);

  // ── Expose colors for the few places that still need them ────
  // (e.g. HomePage decorative circles, StepDot darkBlue)
  static const lightPrimary   = _lightPrimary;
  static const lightSecondary = _lightSecondary;
  static const darkBlueTone   = _lightDarkBlue;   // legacy name kept
  static const cardBackground = _lightCardBg;     // legacy name kept

  // ── Light theme ──────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Georgia',
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary:    _lightPrimary,
      secondary:  _lightSecondary,
      surface:    _lightSurface,
      onPrimary:  Colors.white,
      onSecondary: Colors.white,
      onSurface:  _lightPrimary,
    ),

    scaffoldBackgroundColor: _lightScaffold,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: _lightPrimary),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _lightPrimary, letterSpacing: 0.2),
      bodySmall: TextStyle(fontSize: 12.5, height: 1.5, color: _lightSubtleText),
      labelSmall: TextStyle(fontSize: 11, color: _lightHint),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _lightPrimary),
      labelLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _lightPrimary),
      titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
    ),

    iconTheme: const IconThemeData(color: _lightIconColor, size: 19),

    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightFill,
      hintStyle: const TextStyle(color: _lightHint, fontSize: 13.5, fontWeight: FontWeight.normal),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _lightBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _lightBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _lightSecondary, width: 1.5)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFCCCCCC),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimary,
        side: const BorderSide(color: _lightChipBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? _lightSecondary : Colors.transparent),
      checkColor: WidgetStateProperty.all(_lightPrimary),
      side: const BorderSide(color: Color(0xFFBBB49A), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );

  // ── Dark theme ───────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Georgia',
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary:    _darkPrimary,
      secondary:  _darkSecondary,
      surface:    _darkSurface,
      onPrimary:  _darkScaffold,
      onSecondary: _darkScaffold,
      onSurface:  _darkPrimary,
    ),

    scaffoldBackgroundColor: _darkScaffold,

    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: _darkPrimary),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _darkPrimary, letterSpacing: 0.2),
      bodySmall: TextStyle(fontSize: 12.5, height: 1.5, color: _darkSubtleText),
      labelSmall: TextStyle(fontSize: 11, color: _darkHint),
      titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _darkPrimary),
      labelLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _darkPrimary),
      titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _darkPrimary),
    ),

    iconTheme: const IconThemeData(color: _darkIconColor, size: 19),

    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkFill,
      hintStyle: const TextStyle(color: _darkHint, fontSize: 13.5, fontWeight: FontWeight.normal),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _darkBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _darkBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _darkSecondary, width: 1.5)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkSecondary,        // gold CTA on dark
        foregroundColor: _darkScaffold,
        disabledBackgroundColor: const Color(0xFF2A3A4A),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimary,
        side: const BorderSide(color: _darkChipBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? _darkSecondary : Colors.transparent),
      checkColor: WidgetStateProperty.all(_darkScaffold),
      side: const BorderSide(color: _darkIconColor, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}