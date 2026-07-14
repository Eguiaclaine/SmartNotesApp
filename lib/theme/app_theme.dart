import 'package:flutter/material.dart';

class AppColors {
  /// Candy pink brand seed
  static const seed = Color(0xFFFF4D8D);
  static const candyPink = Color(0xFFFF8FB8);
  static const candyBlush = Color(0xFFFFD6E7);
  static const candyRose = Color(0xFFFF6B9D);
  static const lightBackground = Color(0xFFFFF5F8);

  static const spacePalette = <Color>[
    Color(0xFFFF8FB8),
    Color(0xFFFF6B9D),
    Color(0xFFFFB3C9),
    Color(0xFFFF85A8),
    Color(0xFFE85A8C),
    Color(0xFFFF9EC4),
    Color(0xFFFF5C9A),
    Color(0xFFF7A8C8),
  ];

  static Color parseHex(String hex, {Color fallback = candyPink}) {
    var value = hex.trim().replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    if (value.length != 8) return fallback;
    return Color(int.parse(value, radix: 16));
  }

  static String toHex(Color color) {
    final value = color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${value.substring(2)}';
  }
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
      primary: AppColors.candyRose,
      secondary: AppColors.candyPink,
      tertiary: const Color(0xFFFFADCE),
      surface: Colors.white,
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    final radius = BorderRadius.circular(16);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(borderRadius: radius),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface.withValues(alpha: 0.85),
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: radius),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: radius),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.45)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}
