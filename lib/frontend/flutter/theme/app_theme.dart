import 'package:flutter/material.dart';

/// The app's color identity. Green primary, white surfaces.
/// Seeded into Material 3 so component colors (buttons, switches,
/// navigation, focus rings) derive consistently without hand-tuning.
class AppTheme {
  const AppTheme._();

  /// The brand green. Tweak the shade here and every derived
  /// color follows.
  static const Color brandGreen = Color(0xFF2E7D32); // Material Green 800

  /// A darker shade for pressed/active states where M3's tonal
  /// derivation doesn't go far enough.
  static const Color brandGreenDark = Color(0xFF1B5E20); // Green 900

  /// The surface color. Pure white, no tint.
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  /// A very light green wash for selected rows, chips, etc. Reads
  /// as "white but on-brand" without being loud.
  static const Color surfaceGreenTint = Color(0xFFF1F8F2);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandGreen,
      brightness: Brightness.light,
      surface: surfaceWhite,
    ).copyWith(
      // Force pure white surfaces; M3's seed derivation tints them
      // slightly green by default, which reads as off-white.
      surface: surfaceWhite,
      surfaceContainerLowest: surfaceWhite,
      surfaceContainerLow: surfaceWhite,
      primary: brandGreen,
      onPrimary: Colors.white,
      primaryContainer: surfaceGreenTint,
      onPrimaryContainer: brandGreenDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surfaceWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: brandGreenDark,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: brandGreenDark,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brandGreen,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: brandGreenDark),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandGreenDark,
          side: const BorderSide(color: brandGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: brandGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class AppSpacing {
  const AppSpacing._();
  static const double screenPadding = 16;
  static const double sectionGap = 24;
  static const double tileGap = 8;
}

class AppRadius {
  const AppRadius._();
  static const double button = 10;
  static const double card = 12;
  static const double input = 10;
}