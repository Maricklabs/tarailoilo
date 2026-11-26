import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/app/theme.dart';
import 'package:image_picker/image_picker.dart';

/* ---------------------------------------------------------------- Logo */

class Logo extends StatelessWidget {
  const Logo({super.key, this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final width = small
        ? (w * 0.28).clamp(130.0, 200.0).toDouble()
        : (w * 0.38).clamp(170.0, 260.0).toDouble();
    return Image.asset(
      assetImg('logo'),
      width: width,
      semanticLabel: 'TARA ILOILO',
      errorBuilder: (_, __, ___) => Text(
        'TARA ILOILO',
        style: jost(size: 32, weight: FontWeight.w700, color: AppColors.brown),
      ),
    );
  }
}

/* -------------------------------------------------------- Glass button */

const String _googleG = '''
<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 48 48">
<path fill="#EA4335" d="M24 9.5c3.5 0 6.6 1.2 9.1 3.6l6.8-6.8C35.8 2.4 30.3 0 24 0 14.6 0 6.5 5.4 2.6 13.2l7.9 6.1C12.4 13.6 17.7 9.5 24 9.5z"/>
<path fill="#4285F4" d="M46.5 24.5c0-1.6-.1-3.1-.4-4.5H24v9h12.7c-.6 3-2.3 5.5-4.8 7.2l7.6 5.9c4.4-4.1 7-10.1 7-17.6z"/>
<path fill="#FBBC05" d="M10.5 28.7c-.5-1.4-.8-3-.8-4.7s.3-3.2.8-4.7l-7.9-6.1C1 16.4 0 20.1 0 24s1 7.6 2.6 10.8l7.9-6.1z"/>
<path fill="#34A853" d="M24 48c6.5 0 11.9-2.1 15.9-5.8l-7.6-5.9c-2.1 1.4-4.9 2.3-8.3 2.3-6.3 0-11.6-4.1-13.5-9.8l-7.9 6.1C6.5 42.6 14.6 48 24 48z"/>
</svg>''';

Widget googleLogo() => SvgPicture.string(_googleG, width: 20, height: 20);

enum GlassColor { orange, purple, google, deep, pink }

/// Glass button: translucent by default, solid + scaled down while pressed.
/// Runs [onPressed] after a visible press (260 ms), like the React version.
class GlassButton extends StatefulWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.color = GlassColor.orange,
    this.onPressed,
    this.disabled = false,
    this.fit = false,
    this.width,
    this.minWidth,
    this.minHeight,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.gap = 10,
    this.leadingBuilder,
    this.showLabel = true,
    this.askStyle = false,
  });

  final String label;
  final GlassColor color;
  final FutureOr<void> Function()? onPressed;
  final bool disabled;
  final bool fit; // shrink-wrap instead of full width (min 120)
  final double? width; // fixed width (animates when it changes)
  final double? minWidth;
  final double? minHeight;
  final EdgeInsets? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double gap;
  final Widget Function(Color textColor)? leadingBuilder;
  final bool showLabel;
  final bool askStyle; // dashboard "Ask TATA" pressed look

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _down = false;
  bool _solid = false;
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy || widget.disabled) return;
    setState(() {
      _busy = true;
      _solid = true;
      _down = true;
    });
    await Future.delayed(const Duration(milliseconds: 260)); // visible press before the action runs
    if (mounted) setState(() => _down = false);
    try {
      await widget.onPressed?.call();
    } finally {
      await Future.delayed(const Duration(milliseconds: 160));
      if (mounted) {
        setState(() {
          _solid = false;
          _busy = false;
        });
      }
    }
  }

  void _press() {
    if (!_busy && !widget.disabled) setState(() => _down = true);
  }

  void _release() {
    if (!_busy) setState(() => _down = false);
  }

  @override
  Widget build(BuildContext context) {
    final isGoogle = widget.color == GlassColor.google;
    final pressed = _down || _solid;

    final (int r, int g, int b) = switch (widget.color) {
      GlassColor.orange => (192, 123, 81),
      GlassColor.purple => (165, 70, 136),
      GlassColor.pink => (165, 70, 136),
      GlassColor.deep => (121, 32, 94),
      GlassColor.google => (0, 0, 0),
    };
    Color c(double a) => Color.fromRGBO(r, g, b, a);
    final solidC = Color.fromRGBO(r, g, b, 1);

    final Color textNormal = switch (widget.color) {
      GlassColor.orange => AppColors.brownInk,
      GlassColor.purple => const Color(0xFF7D2F66),
      GlassColor.google => Colors.black,
      GlassColor.deep => Colors.white,
      GlassColor.pink => AppColors.deep,
    };
    final Color textColor = !pressed
        ? textNormal
        : isGoogle
            ? Colors.black
            : widget.askStyle
                ? AppColors.deep
                : Colors.white;

    List<Color> gradient;
    Color border;
    List<BoxShadow> shadow;
    if (isGoogle) {
      if (pressed) {
        gradient = const [Colors.white, Colors.white];
        border = rgba(0, 0, 0, .25);
        shadow = [BoxShadow(color: rgba(0, 0, 0, .18), blurRadius: 8, offset: const Offset(0, 3))];
      } else {
        gradient = [rgba(255, 255, 255, .55), rgba(255, 255, 255, .55)];
        border = rgba(0, 0, 0, .14);
        shadow = [BoxShadow(color: rgba(0, 0, 0, .12), blurRadius: 16, offset: const Offset(0, 6))];
      }
    } else if (pressed && widget.askStyle) {
      gradient = const [Colors.white, Colors.white];
      border = AppColors.deep;
      shadow = [BoxShadow(color: rgba(121, 32, 94, .25), blurRadius: 10, offset: const Offset(0, 3))];
    } else if (pressed) {
      gradient = [solidC, solidC];
      border = solidC;
      shadow = [BoxShadow(color: c(.45), blurRadius: 8, offset: const Offset(0, 3))];
    } else {
      gradient = [c(.62), c(.42)];
      border = rgba(255, 255, 255, .7);
      shadow = [BoxShadow(color: c(.35), blurRadius: 20, offset: const Offset(0, 8))];
    }

    final fontSize = widget.fontSize ?? (isGoogle ? 13.6 : 16);
    final weight = widget.fontWeight ?? (isGoogle ? FontWeight.w500 : FontWeight.w600);
    final padding = widget.padding ??
        (isGoogle
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 12));
    final shrink = widget.fit || isGoogle || widget.width != null;
    final minWidth = widget.minWidth ?? (isGoogle ? 200.0 : (widget.fit ? 120.0 : 0.0));
    final minHeight = widget.minHeight ?? (isGoogle ? 42.0 : 50.0);

    Widget? leading;
    if (isGoogle) {
      leading = googleLogo();
    } else if (widget.leadingBuilder != null) {
      leading = widget.leadingBuilder!(textColor);
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) leading,
        if (leading != null && widget.showLabel) SizedBox(width: widget.gap),
        if (widget.showLabel)
          Flexible(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 350),
              style: jost(
                size: fontSize, 
                weight: weight, 
                color: textColor),
              child: Text(widget.label, maxLines: 1, softWrap: false, overflow: TextOverflow.clip),
            ),
          ),
      ],
    );

    final double? fixedWidth = widget.width ?? (shrink ? null : double.infinity);

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press(),
        onTapUp: (_) => _release(),
        onTapCancel: _release,
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _down ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 160),
          child: Opacity(
            opacity: widget.disabled ? 0.6 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.ease,
              width: fixedWidth,
              constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: shadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.ease,
                    padding: padding,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      ),
                      border: Border.all(color: border, width: 1),
                    ),
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ----------------------------------------------------------- ClickLink */

/// Text that underlines briefly on tap, then runs its action (350 ms later).
class ClickLink extends StatefulWidget {
  const ClickLink({
    super.key,
    required this.text,
    required this.onTap,
    this.color = Colors.black,
    this.fontSize = 16,
  });

  final String text;
  final VoidCallback onTap;
  final Color color;
  final double fontSize;

  @override
  State<ClickLink> createState() => _ClickLinkState();
}

class _ClickLinkState extends State<ClickLink> {
  bool _on = false;

  void _handle() {
    setState(() => _on = true);
    Future.delayed(const Duration(milliseconds: 350), () => widget.onTap());
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _on = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handle,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: jost(
          size: widget.fontSize,
          weight: FontWeight.w700,
          color: widget.color,
          decoration: TextDecoration.underline,
          decorationColor: _on ? widget.color : const Color(0x00000000),
        ),
        child: Text(widget.text),
      ),
    );
  }
}

/* -------------------------------------------------------------- Fields */

const String _mailSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/></svg>';
const String _lockSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></svg>';

enum FieldIcon { mail, lock }

Widget _fieldIcon(FieldIcon i) =>
    SvgPicture.string(i == FieldIcon.mail ? _mailSvg : _lockSvg, width: 16, height: 16);

const Color _fieldGrey = Color(0xFF9B9B9B);

/// Floating-label text field (CSS `.field`).
class FloatingInput extends StatefulWidget {
  const FloatingInput({
    super.key,
    required this.label,
    required this.onChanged,
    this.error,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.onSubmitted,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final String? error;
  final FieldIcon? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;

  @override
  State<FloatingInput> createState() => _FloatingInputState();
}

class _FloatingInputState extends State<FloatingInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focus = _focus.hasFocus;
    final raised = focus || _controller.text.isNotEmpty;
    final hasError = widget.error != null;
    final hasIcon = widget.icon != null;
    final borderColor = hasError ? AppColors.pink : (raised ? AppColors.brown : _fieldGrey);

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 6),
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                constraints: const BoxConstraints(minHeight: 50),
                padding: EdgeInsets.only(
                  top: 22,
                  bottom: 8,
                  left: hasIcon && raised ? 24 : 0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: borderColor, width: focus ? 3.0 : 1.5)),
                  boxShadow: focus
                      ? [BoxShadow(color: borderColor, offset: const Offset(0, 1.5))]
                      : const [],
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  obscureText: widget.obscure,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: AppColors.brown,
                  style: jost(size: 16, weight: FontWeight.w500, color: const Color(0xFF222222)),
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (hasIcon)
                Positioned(
                  left: 0,
                  bottom: 13,
                  child: AnimatedOpacity(
                    opacity: raised ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: _fieldIcon(widget.icon!),
                  ),
                ),
              Positioned(
                left: 0,
                top: 22,
                child: IgnorePointer(
                  child: _FloatingLabel(label: widget.label, raised: raised, focus: focus),
                ),
              ),
            ],
          ),
          if (hasError) _FieldError(widget.error!),
        ],
      ),
    );
  }
}

class _FloatingLabel extends StatelessWidget {
  const _FloatingLabel({required this.label, required this.raised, required this.focus});
  final String label;
  final bool raised;
  final bool focus;

  @override
  Widget build(BuildContext context) {
    final scale = raised ? 0.8 : 1.0;
    final ty = raised ? -22.0 : 0.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
      transformAlignment: Alignment.topLeft,
      transform: Matrix4.translationValues(0, ty, 0) * Matrix4.diagonal3Values(scale, scale, 1),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: jost(
          size: 15.2,
          weight: FontWeight.w600,
          color: focus ? AppColors.brown : Colors.black,
        ),
        child: Text(label),
      ),
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(text, style: jost(size: 13.12, weight: FontWeight.w600, color: AppColors.pink)),
    );
  }
}

/// Error line under a field/form (public so screens can reuse the style).
class FormError extends StatelessWidget {
  const FormError(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(text, style: jost(size: 13.12, weight: FontWeight.w600, color: AppColors.pink)),
    );
  }
}

/// Floating-label dropdown (CSS `.field.select`). Opens a bottom sheet.
class FloatingSelect extends StatefulWidget {
  const FloatingSelect({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.error,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? error;

  @override
  State<FloatingSelect> createState() => _FloatingSelectState();
}

class _FloatingSelectState extends State<FloatingSelect> {
  bool _open = false;

  Future<void> _pick() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _open = true);
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final o in widget.options)
                InkWell(
                  onTap: () => Navigator.of(ctx).pop(o),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Text(
                      o,
                      style: jost(
                        size: 16,
                        weight: o == widget.value ? FontWeight.w700 : FontWeight.w500,
                        color: o == widget.value ? AppColors.brown : const Color(0xFF222222),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (mounted) setState(() => _open = false);
    if (chosen != null) widget.onChanged(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final raised = _open || widget.value.isNotEmpty;
    final hasError = widget.error != null;
    final borderColor = hasError ? AppColors.pink : (raised ? AppColors.brown : _fieldGrey);

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 6),
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pick,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 50),
                  padding: const EdgeInsets.only(top: 22, bottom: 8, right: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: borderColor, width: _open ? 3.0 : 1.5)),
                    boxShadow: _open
                        ? [BoxShadow(color: borderColor, offset: const Offset(0, 1.5))]
                        : const [],
                  ),
                  child: Text(
                    widget.value.isEmpty ? ' ' : widget.value,
                    style: jost(size: 16, weight: FontWeight.w500, color: const Color(0xFF222222)),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 32,
                  child: Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.black, width: 2),
                          bottom: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 22,
                  child: IgnorePointer(
                    child: _FloatingLabel(label: widget.label, raised: raised, focus: _open),
                  ),
                ),
              ],
            ),
          ),
          if (hasError) _FieldError(widget.error!),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------ Checkbox */

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.label,
    this.error,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final Widget label;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: SizedBox(
                  width: 22,
                  height: 20,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: checked,
                        onChanged: (v) => onChanged(v ?? false),
                        activeColor: AppColors.brown,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        side: const BorderSide(color: Color(0xFF767676), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(!checked),
                  child: label,
                ),
              ),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 4),
              child: Text(error!, style: jost(size: 13.12, weight: FontWeight.w600, color: AppColors.pink)),
            ),
        ],
      ),
    );
  }
}

/* --------------------------------------------------------- Back button */

const String _backSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#7a3d17" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 14 4 9l5-5"/><path d="M4 9h10.5a5.5 5.5 0 0 1 0 11H11"/></svg>';

class AppBackButton extends StatefulWidget {
  const AppBackButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<AppBackButton> createState() => _AppBackButtonState();
}

class _AppBackButtonState extends State<AppBackButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: () => Future.delayed(const Duration(milliseconds: 120), widget.onTap),
        child: AnimatedScale(
          scale: _down ? 0.82 : 1,
          duration: const Duration(milliseconds: 120),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(child: SvgPicture.string(_backSvg, width: 26, height: 26)),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------------------------------- Avatar picker */

const List<String> kAvatars = [
  'banana', 'budyawi', 'jackfruit', 'kamachile', 'lanzones', 'mango',
];

/// 5 avatars on the first row, the 6th + an upload "+" tile on the second.
/// [value] is an avatar name, 'custom' (uploaded photo) or '' (nothing yet).
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.value,
    required this.customPath,
    required this.onChanged,
    this.error,
    this.allowCustom = true,
    this.showLabel = true,
  });

  final String value;
  final String? customPath;
  final void Function(String value, String? customPath) onChanged;
  final String? error;
  final bool allowCustom;
  final bool showLabel;

  Future<void> _import() async {
    try {
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (x != null) onChanged('custom', x.path);
    } catch (_) {
      // picker cancelled or unavailable; keep the current choice
    }
  }

  Widget _tile(double size, bool selected, VoidCallback onTap, Widget child, String label) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.pur : Colors.transparent,
              width: 3,
            ),
          ),
          child: ClipOval(child: child),
        ),
      ),
    );
  }

  Widget _avatar(String name) => Image.asset(
        'assets/avatars/$name.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFF9E3F1), Color(0xFFE7B6D5)]),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel) ...[
            Text('Select Avatar:', style: jost(size: 15.2, weight: FontWeight.w600)),
            const SizedBox(height: 12),
          ],
          LayoutBuilder(builder: (context, c) {
            const gap = 6.0;
            final size = (c.maxWidth - gap * 4) / 5;
            final hasCustom = customPath != null;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (var i = 0; i < 5; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      _tile(size, value == kAvatars[i], () => onChanged(kAvatars[i], customPath),
                          _avatar(kAvatars[i]), 'Avatar ${i + 1}'),
                    ],
                  ],
                ),
                const SizedBox(height: gap),
                Row(
                  children: [
                    _tile(size, value == kAvatars[5], () => onChanged(kAvatars[5], customPath),
                        _avatar(kAvatars[5]), 'Avatar 6'),
                    const SizedBox(width: gap),
                      if (allowCustom)
                        _tile(
                          size,
                          value == 'custom',
                          _import,
                          hasCustom
                              ? Image.file(File(customPath!), fit: BoxFit.cover)
                              : Container(
                                  color: rgba(205, 123, 180, .18),
                                  child: const Icon(Icons.add, color: AppColors.pur, size: 28),
                                ),
                          'Upload your own photo',
                        ),
                  ],
                ),
              ],
            );
          }),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(error!, style: jost(size: 13.12, weight: FontWeight.w600, color: AppColors.pink)),
            ),
        ],
      ),
    );
  }
}
