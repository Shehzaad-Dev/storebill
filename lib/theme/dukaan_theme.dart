import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from original DukaanDoc UI — refined for Material 3 dark.
abstract final class DukaanColors {
  static const Color black = Color(0xFF0A0A0A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color g1 = Color(0xFFF8F8F8);
  static const Color g2 = Color(0xFFF0F0F0);
  static const Color g3 = Color(0xFFE0E0E0);
  static const Color g4 = Color(0xFF999999);
  static const Color g5 = Color(0xFF555555);
  static const Color green = Color(0xFF16A34A);
  static const Color red = Color(0xFFDC2626);
  static const Color navInactive = Color(0xFF555555);
  static const Color chipBg = Color(0xFF1A1A1A);
  static const Color chipBorder = Color(0xFF2A2A2A);

  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkOnSurface = Color(0xFFF5F5F5);
  static const Color darkOnSurfaceVariant = Color(0xFFB3B3B3);
}

ThemeData buildDukaanTheme({required bool dark}) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: dark ? DukaanColors.darkBg : DukaanColors.g1,
    splashFactory: InkSparkle.splashFactory,
  );

  final scheme = ColorScheme(
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: DukaanColors.black,
    onPrimary: Colors.white,
    secondary: dark ? DukaanColors.darkSurfaceVariant : DukaanColors.g2,
    onSecondary: dark ? DukaanColors.darkOnSurface : DukaanColors.black,
    error: DukaanColors.red,
    onError: Colors.white,
    surface: dark ? DukaanColors.darkSurface : DukaanColors.white,
    onSurface: dark ? DukaanColors.darkOnSurface : DukaanColors.black,
    surfaceContainerHighest: dark ? DukaanColors.darkSurfaceVariant : DukaanColors.g2,
    outline: dark ? const Color(0xFF3A3A3A) : DukaanColors.g3,
    outlineVariant: dark ? const Color(0xFF404040) : DukaanColors.g3,
  );

  final textTheme = GoogleFonts.dmSansTextTheme(
    dark
        ? base.textTheme.apply(
            bodyColor: DukaanColors.darkOnSurfaceVariant,
            displayColor: DukaanColors.darkOnSurface,
          )
        : base.textTheme,
  );

  return base.copyWith(
    colorScheme: scheme,
    textTheme: textTheme,
    cardTheme: CardThemeData(
      color: dark ? DukaanColors.darkSurface : DukaanColors.white,
      elevation: dark ? 0 : 0.4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? DukaanColors.darkSurfaceVariant : DukaanColors.g1,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: dark ? DukaanColors.darkOnSurface : DukaanColors.black, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      isDense: true,
    ),
    dividerTheme: DividerThemeData(color: scheme.outline.withValues(alpha: 0.35), thickness: 0.5),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
  );
}
