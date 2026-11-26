import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for TaraIlo.
///
/// TODO(ui-team): replace these PLACEHOLDER values with the colors, fonts and
/// radii from the team's Figma mood board / hi-fi prototype. Every widget
/// should read colors from `Theme.of(context).colorScheme` (never hard-coded
/// hex values) so changing the tokens here restyles the whole app.

Color rgba(int r, int g, int b, double a) => Color.fromRGBO(r, g, b, a);

/// Design tokens copied from the React CSS variables.
class AppColors {
  static const pink = Color(0xFFA54688);
  static const brown = Color(0xFFC07B51);
  static const brownInk = Color(0xFF7A3D17);
  static const bright = Color(0xFFDE19A2);
  static const pur = Color(0xFFA54688);
  static const deep = Color(0xFF79205E);
  static const lite = Color(0xFFCD7BB4);
  static const soft = Color(0xFF6B6270);
  static const ink = Color(0xFF2A2230);
}

/// Jost, the font used by the React app.
TextStyle jost({
  double size = 16,
  FontWeight weight = FontWeight.w400,
  Color color = Colors.black,
  double? height,
  double? letterSpacing,
  TextDecoration decoration = TextDecoration.none,
  Color? decorationColor,
}) {
  return GoogleFonts.jost(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
    decorationColor: decorationColor,
  );
}

/// cubic-bezier(.2, .8, .25, 1) - the main "rise" curve of the design.
const Curve kEase = Cubic(0.2, 0.8, 0.25, 1);

String assetImg(String name) => 'assets/images/$name.png';

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
      seedColor: AppColors.pink,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      // TODO(ui-team): set fontFamily / textTheme from Figma typography.
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
