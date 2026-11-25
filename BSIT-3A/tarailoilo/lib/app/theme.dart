import 'package:flutter/material.dart';

/// Design tokens for TaraIlo.
///
/// TODO(ui-team): replace these PLACEHOLDER values with the colors, fonts and
/// radii from the team's Figma mood board / hi-fi prototype. Every widget
/// should read colors from `Theme.of(context).colorScheme` (never hard-coded
/// hex values) so changing the tokens here restyles the whole app.
abstract final class AppColors {
  /// Placeholder brand seed color. Swap for the Figma primary color.
  static const Color seed = Color(0xFF1E6F5C);
}

/// Spacing scale shared by all screens so layouts stay consistent.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Builds the Material 3 [ThemeData] for light and dark mode.
abstract final class AppTheme {
  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // TODO(ui-team): set fontFamily / textTheme from Figma typography.
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
