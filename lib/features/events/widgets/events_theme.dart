import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme.dart';

/// Colors and fonts from the team's Figma "Events" / "Event Details" frames.
///
/// Applied to the Events screens only (team decision). When the whole app
/// adopts the Figma style, move these into lib/app/theme.dart.
abstract final class EventsColors {
  /// Header background and location pill.
  static const orange = Color(0xFFFF7A00);

  /// "Ongoing Events" and "History" headings.
  static const crimson = Color(0xFFD61F45);

  /// Event time in the detail header and distance text.
  static const yellow = Color(0xFFFFE04A);

  /// Event card title text.
  static const cardTitle = Color(0xFF5B3A3A);

  /// Card borders and the search field outline.
  static const border = Color(0xFFE3DCDC);
}

/// Wraps the Events screens in the Figma look (Poppins + orange accents).
class EventsTheme extends StatelessWidget {
  const EventsTheme({super.key, required this.child});

  final Widget child;

  /// Light theme with Poppins text. The Figma design is light-only, so the
  /// Events screens stay light even when the phone is in dark mode (the
  /// fixed brown/orange colors would be unreadable on a dark background).
  ///
  /// google_fonts downloads Poppins once and caches it; with no internet on
  /// first launch it falls back to the default font.
  static ThemeData of(BuildContext context) {
    final base = AppTheme.light();
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      colorScheme: base.colorScheme.copyWith(primary: EventsColors.orange),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: EventsColors.orange.withValues(alpha: 0.18),
        side: const BorderSide(color: EventsColors.border),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(data: of(context), child: child);
}
