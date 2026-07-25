import 'package:flutter/material.dart';

/// Material 3 theme for the School Management System.
///
/// Visual language follows the mobile design reference:
/// soft gray canvas, borderless white cards with large radii, indigo/violet
/// primary, pill-shaped inputs & chips, and a bottom navigation bar whose
/// selected icon sits in a rounded indigo square.
class AppTheme {
  AppTheme._();

  /// Light, modern lavender-violet — an airier take on the reference purple.
  static const seed = Color(0xFF8B7CF6);

  /// Accent palette used by stat tiles & charts (mirrors the reference tiles).
  static const tileOrange = Color(0xFFF2734D);
  static const tileBlue = Color(0xFF5B8DEF);
  static const tileAmber = Color(0xFFF5A54A);
  static const tileGreen = Color(0xFF57B894);
  static const tilePink = Color(0xFFE2618B);
  static const tileViolet = Color(0xFF8B7CF6);

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    var scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    // fromSeed darkens the primary tone in light mode; pin the actual light
    // lavender so buttons/nav indicator keep the airy look.
    if (!isDark) {
      scheme = scheme.copyWith(primary: seed, onPrimary: Colors.white);
    }

    final cardColor = isDark ? const Color(0xFF1C1D26) : Colors.white;
    final canvas = isDark ? const Color(0xFF12131A) : const Color(0xFFF4F4F7);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(surface: cardColor),
      scaffoldBackgroundColor: canvas,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: canvas,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: isDark
              ? BorderSide.none
              : BorderSide(color: Colors.black.withValues(alpha: .05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        surfaceTintColor: Colors.transparent,
        backgroundColor: cardColor,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .5)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        // Compact bar: the OS bottom safe-area inset is added below this,
        // so anything taller leaves a large dead zone on iPhones.
        height: 60,
        elevation: 0,
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary,
        indicatorShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 26,
            color: states.contains(WidgetState.selected)
                ? Colors.white
                : scheme.onSurfaceVariant.withValues(alpha: .8),
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardColor,
        indicatorColor: scheme.primary.withValues(alpha: .12),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: .4),
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}
