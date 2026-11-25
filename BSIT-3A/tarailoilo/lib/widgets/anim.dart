import 'dart:async';
import 'package:flutter/material.dart';
import '../theme.dart';

/// One-shot entrance animation (opacity + translate + scale) with a delay.
/// Mirrors the CSS `animation: ... both` keyframes used in the React app.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.curve = kEase,
    this.from = Offset.zero,
    this.fromScale = 1.0,
    this.fade = true,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset from; // starting translate, in logical pixels
  final double fromScale;
  final bool fade;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = widget.curve.transform(_c.value);
        return Opacity(
          opacity: widget.fade ? t.clamp(0.0, 1.0).toDouble() : 1.0,
          child: Transform.translate(
            offset: widget.from * (1 - t),
            child: Transform.scale(
              scale: widget.fromScale + (1 - widget.fromScale) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Slides down from the top into place (CSS `.rise`).
class Rise extends StatelessWidget {
  const Rise({super.key, this.d = 0.4, required this.child});
  final double d;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Entrance(
      delay: Duration(milliseconds: (d * 1000).round()),
      duration: const Duration(milliseconds: 700),
      curve: kEase,
      from: const Offset(0, -60),
      child: child,
    );
  }
}

/// Screen fade-in (CSS `screenIn .4s ease`).
class FadeIn extends StatelessWidget {
  const FadeIn({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Entrance(
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
      child: child,
    );
  }
}
