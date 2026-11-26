import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Clean SVG icons, all stroke="currentColor"; the colour is applied by [Icn].
String _svg(String inner) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">$inner</svg>';

class Ic {
  static final String home = _svg(
      '<path d="M3 11.5 12 4l9 7.5"/><path d="M5.5 10v9.5h13V10"/><path d="M10 19.5v-5h4v5"/>');
  static final String dining = _svg(
      '<circle cx="12" cy="12" r="4.2"/><path d="M3 3.5v4.6a1.6 1.6 0 0 0 3.2 0V3.5M4.6 3.5v17"/><path d="M20.5 20.5v-17c-2 1.5-2.8 4-2.8 7.5h2.8"/>');
  static final String map = _svg(
      '<path d="M9 4 3.5 6v14L9 18l6 2 5.5-2V4L15 6 9 4z"/><path d="M9 4v14M15 6v14"/>');
  static final String language = _svg(
      '<path d="M4 6h9M8.5 4v2M6 6c.5 3 2.5 5.5 5.5 7M11 6c-.5 3-3 6-7 8"/><path d="m12.5 20 4-9 4 9M14 17h5"/>');
  static final String events = _svg(
      '<rect x="3.5" y="5" width="17" height="15" rx="2.5"/><path d="M3.5 10h17M8 3v4M16 3v4M9 15l2 2 4-4"/>');
  static final String camera =
      _svg('<path d="M4 8h3l1.5-2h7L17 8h3v11H4z"/><circle cx="12" cy="13" r="3.5"/>');
  static final String route = _svg(
      '<circle cx="6" cy="18" r="2"/><circle cx="18" cy="6" r="2"/><path d="M8 18h7a3 3 0 0 0 0-6H9a3 3 0 0 1 0-6h7"/>');
  static final String search =
      _svg('<circle cx="11" cy="11" r="6.5"/><path d="m16 16 4.5 4.5"/>');
  static final String pin = _svg(
      '<path d="M12 21s7-6.2 7-11.5a7 7 0 0 0-14 0C5 14.8 12 21 12 21z"/><circle cx="12" cy="9.5" r="2.5"/>');
  static final String user = _svg(
      '<circle cx="12" cy="8.5" r="3.7"/><path d="M4.5 20c.8-4 3.8-6 7.5-6s6.7 2 7.5 6"/>');
  static final String arrow = _svg('<path d="M5 12h14M13 6l6 6-6 6"/>');
  static final String back = _svg('<path d="M19 12H5M11 6l-6 6 6 6"/>');
  static final String close = _svg('<path d="M6 6l12 12M18 6 6 18"/>');
  static final String send = _svg('<path d="M22 2 11 13"/><path d="M22 2 15 22l-4-9-9-4z"/>');
}

/// Draws one of the [Ic] icons in the given colour (like CSS currentColor).
class Icn extends StatelessWidget {
  const Icn(this.svg, {super.key, this.size = 24, required this.color});
  final String svg;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
