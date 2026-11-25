import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import 'anim.dart';
import 'element_design.dart';

/// Positions follow the Figma frames. l/t = left/top as % of the header,
/// w = width as % of the header width, r = rotation in degrees.
/// n = file name in assets/images (without .png).
class Ingredient {
  const Ingredient(this.n, this.l, this.t, this.w, this.r);
  final String n;
  final double l, t, w, r;
}

const List<Ingredient> kIngredients = [
  Ingredient('celery', 33, 6, 8, 70),
  Ingredient('pork2', 50, 11, 12.5, 20),
  Ingredient('chicharon', 15, 12, 13.5, -10),
  Ingredient('chicharon', 69, 2, 7.5, 15),
  Ingredient('celery', 79, 16, 12, -30),
  Ingredient('chicharon2', 39, 29, 4.5, 0),
  Ingredient('celery', 3, 29, 14, 25),
  Ingredient('pork1', 51, 33, 11, 0),
  Ingredient('chicharon', 82, 40, 10.5, -15),
  Ingredient('pork3', 14, 44, 14, 0),
  Ingredient('chicharon2', 28, 56, 6, 0),
  Ingredient('celery', 72, 56, 9, -20),
  Ingredient('chicharon2', 56, 71, 4.5, 0),
  Ingredient('pork3', 52, 78, 9, 90),
  Ingredient('celery', 22, 81, 16, 25),
];

/// Information screen (shorter header)
const List<Ingredient> kInfoIngredients = [
  Ingredient('celery', 68, -3, 10, -20),
  Ingredient('chicharon2', 53, 32, 3.5, 0),
  Ingredient('pork1', 51, 48, 4.5, 0),
  Ingredient('celery', 22, 58, 15.5, 25),
];

// Natural pixel sizes of the ingredient PNGs (to keep their aspect ratio).
const Map<String, Size> _imgSize = {
  'celery': Size(68, 66),
  'chicharon': Size(59, 67),
  'chicharon2': Size(31, 31),
  'pork1': Size(44, 114),
  'pork2': Size(60, 66),
  'pork3': Size(74, 25),
};

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({this.onBack, this.ingredients, required this.compact});
  final VoidCallback? onBack;
  final List<Ingredient>? ingredients;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = w * (compact ? 205 / 402 : 518 / 402);

      Widget soup = Image.asset(
        assetImg('soup1'),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.fitWidth,
        alignment: Alignment.bottomCenter,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
      if (compact) {
        soup = Entrance(
          from: Offset(0, -h),
          duration: const Duration(milliseconds: 800),
          curve: kEase,
          fade: false,
          child: soup,
        );
      }

      final list = ingredients;
      return Container(
        width: w,
        height: h,
        color: Colors.white,
        child: ClipRect(
          child: Stack(
            children: [
              Positioned.fill(child: soup),
              if (list != null)
                for (var i = 0; i < list.length; i++) _ingredient(list[i], i, w, h),
              if (onBack != null)
                Positioned(
                  top: math.max(12.0, topInset),
                  left: 10,
                  child: AppBackButton(onTap: onBack!),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _ingredient(Ingredient g, int i, double w, double h) {
    final iw = g.w / 100 * w;
    final size = _imgSize[g.n] ?? const Size(1, 1);
    final ih = iw * size.height / size.width;
    return Positioned(
      left: g.l / 100 * w,
      top: g.t / 100 * h,
      width: iw,
      child: Entrance(
        delay: Duration(milliseconds: ((0.1 + i * 0.07) * 1000).round()),
        duration: const Duration(milliseconds: 1000),
        curve: kEase,
        from: Offset(0, -3 * ih),
        child: Transform.rotate(
          angle: g.r * math.pi / 180,
          child: Image.asset(
            assetImg(g.n),
            width: iw,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

/// Shared shell for Login, Sign In and Information.
/// Starts empty; the first tap anywhere reveals ingredients + form.
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    this.onBack,
    required this.children,
    this.ingredients = kIngredients,
    this.autoReveal = false,
    this.compact = false,
  });

  final VoidCallback? onBack;
  final List<Widget> children;
  final List<Ingredient> ingredients;
  final bool autoReveal;
  final bool compact;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _revealed = widget.autoReveal;

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _revealed ? null : () => setState(() => _revealed = true),
          child: LayoutBuilder(
            builder: (context, cons) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: cons.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: _AuthHeader(
                          onBack: widget.onBack,
                          ingredients: _revealed ? widget.ingredients : null,
                          compact: widget.compact,
                        ),
                      ),
                    ),
                    if (_revealed)
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget.children,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }