import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '/app/theme.dart';
import '../widgets/anim.dart';
import '../widgets/element_design.dart';
import '../data/content.dart';
import 'icons.dart';

Widget tataImage(double size) => Image.asset(
      assetImg('tata'),
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );

/* ------------------------------------------------------------------ Photo */

/// Image with a soft placeholder when the file is missing.
/// [natural] keeps the image's own aspect ratio (width fills, height follows);
/// otherwise the image covers its box (optionally forced to [aspectRatio]).
class Photo extends StatelessWidget {
  const Photo({
    super.key,
    required this.src,
    this.alt = '',
    this.aspectRatio,
    this.natural = false,
    this.radius = 0,
  });

  final String? src;
  final String alt;
  final double? aspectRatio;
  final bool natural;
  final double radius;

  Widget _ph() => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9E3F1), Color(0xFFE7B6D5)],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (natural) {
      final ph = AspectRatio(aspectRatio: aspectRatio ?? 16 / 9, child: _ph());
      child = src == null
          ? ph
          : Image.asset(
              contentSrc(src!),
              width: double.infinity,
              fit: BoxFit.fitWidth,
              semanticLabel: alt,
              errorBuilder: (_, __, ___) => ph,
            );
    } else {
      final inner = src == null
          ? _ph()
          : Image.asset(
              contentSrc(src!),
              fit: BoxFit.cover,
              semanticLabel: alt,
              errorBuilder: (_, __, ___) => _ph(),
            );
      final filled = SizedBox.expand(child: inner);
      child = aspectRatio != null ? AspectRatio(aspectRatio: aspectRatio!, child: filled) : filled;
    }
    return radius > 0 ? ClipRRect(borderRadius: BorderRadius.circular(radius), child: child) : child;
  }
}

/* ----------------------------------------------------------------- Reveal */

/// Fades/slides its child in the first time 12% of it is on screen.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child});
  final Widget child;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  bool _on = false;
  final Key _vkey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _vkey,
      onVisibilityChanged: (info) {
        if (!_on && info.visibleFraction >= 0.12 && mounted) setState(() => _on = true);
      },
      child: AnimatedOpacity(
        opacity: _on ? 1 : 0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.ease,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          curve: Curves.ease,
          transform: Matrix4.translationValues(0, _on ? 0 : 24, 0),
          child: widget.child,
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------- PressCard */

/// Card for landmarks, food and related items (touchdown -> purple -> open).
class PressCard extends StatefulWidget {
  const PressCard({super.key, required this.item, this.onOpen, this.extra = const []});
  final ContentItem item;
  final ValueChanged<ContentItem>? onOpen;
  final List<Widget> extra;

  @override
  State<PressCard> createState() => _PressCardState();
}

class _PressCardState extends State<PressCard> {
  bool _on = false;
  bool _down = false;

  Future<void> _go() async {
    if (_on) return;
    setState(() => _on = true);
    await Future.delayed(const Duration(milliseconds: 280));
    widget.onOpen?.call(widget.item);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _on = false);
  }

  @override
  Widget build(BuildContext context) {
    final on = _on;
    final item = widget.item;
    final soft = on ? rgba(255, 255, 255, .85) : AppColors.soft;
    return AnimatedScale(
      scale: (on || _down) ? 0.97 : 1,
      duration: const Duration(milliseconds: 160),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: _go,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: on ? AppColors.pur : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: on ? AppColors.pur : rgba(205, 123, 180, .55), width: 1.5),
            boxShadow: [
              BoxShadow(color: rgba(165, 70, 136, .13), blurRadius: 18, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Photo(src: item.image, alt: item.name, aspectRatio: 4 / 3),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: jost(size: 16, weight: FontWeight.w600, height: 1.25, color: on ? Colors.white : Colors.black),
                      child: Text(item.name),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: jost(size: 13.6, height: 1.4, color: soft),
                      child: Text(item.short, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    for (final w in widget.extra) ...[
                      const SizedBox(height: 4),
                      DefaultTextStyle.merge(
                        style: jost(size: 12.48, color: on ? rgba(255, 255, 255, .85) : AppColors.pur),
                        child: w,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    Widget small(String t) => Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(t, style: jost(size: 12.48, color: AppColors.pur)),
        );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: rgba(205, 123, 180, .55), width: 1.5),
        boxShadow: [
          BoxShadow(color: rgba(165, 70, 136, .13), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Photo(src: item.image, alt: item.name, aspectRatio: 16 / 9),
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: jost(size: 16, weight: FontWeight.w600, height: 1.25)),
                const SizedBox(height: 4),
                Text(
                  item.short,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: jost(size: 13.6, height: 1.4, color: AppColors.soft),
                ),
                if (item.date != null) small(item.date!),
                if (item.location != null) small(item.location!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------------------------------------------------------- Collection */

/// Snaps the scroll to whole card widths (CSS scroll-snap).
class CardSnapPhysics extends ScrollPhysics {
  const CardSnapPhysics({required this.itemExtent, super.parent});
  final double itemExtent;

  @override
  CardSnapPhysics applyTo(ScrollPhysics? ancestor) =>
      CardSnapPhysics(itemExtent: itemExtent, parent: buildParent(ancestor));

  double _target(ScrollMetrics position, double velocity, Tolerance tol) {
    double page = position.pixels / itemExtent;
    if (velocity < -tol.velocity) {
      page -= 0.5;
    } else if (velocity > tol.velocity) {
      page += 0.5;
    }
    return (page.roundToDouble() * itemExtent)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tol = toleranceFor(position);
    final target = _target(position, velocity, tol);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity, tolerance: tol);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}

class _ArrowButton extends StatefulWidget {
  const _ArrowButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.88 : 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.lite, width: 1.5),
          ),
          child: Center(child: Icn(Ic.arrow, size: 18, color: AppColors.pur)),
        ),
      ),
    );
  }
}

/// Heading + arrow over a horizontal carousel. Arrow = swipe forward by 2 cards
/// (wraps to the start); users can also swipe.
class Collection extends StatefulWidget {
  const Collection({super.key, required this.title, required this.items, required this.onOpen});
  final String title;
  final List<ContentItem> items;
  final ValueChanged<ContentItem> onOpen;

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  final _c = ScrollController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _next() {
    if (!_c.hasClients) return;
    final p = _c.position;
    final atEnd = p.pixels >= p.maxScrollExtent - 4;
    final target = atEnd ? 0.0 : (p.pixels + p.viewportDimension + 14).clamp(0.0, p.maxScrollExtent).toDouble();
    _c.animateTo(target, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      final cardW = (cons.maxWidth - 4 - 14) / 2; // 2 cards + gap inside the 2px side padding
      final n = widget.items.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.title, style: jost(size: 22.4, weight: FontWeight.w600, color: AppColors.pur)),
              const SizedBox(width: 10),
              Semantics(
                button: true,
                label: 'Show next ${widget.title}',
                child: _ArrowButton(onTap: _next),
              ),
            ],
          ),
          SingleChildScrollView(
            controller: _c,
            scrollDirection: Axis.horizontal,
            physics: CardSnapPhysics(itemExtent: cardW + 14),
            padding: const EdgeInsets.fromLTRB(2, 14, 2, 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < n; i++)
                    Padding(
                      padding: EdgeInsets.only(right: i == n - 1 ? 0 : 14),
                      child: SizedBox(
                        width: cardW,
                        child: Entrance(
                          delay: Duration(milliseconds: i * 70),
                          duration: const Duration(milliseconds: 550),
                          curve: kEase,
                          from: const Offset(60, 0),
                          child: PressCard(item: widget.items[i], onOpen: widget.onOpen),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

/* ------------------------------------------------------------------- Hero */

class AccountButton extends StatefulWidget {
  const AccountButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<AccountButton> createState() => _AccountButtonState();
}

class _AccountButtonState extends State<AccountButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Account settings',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.88 : 1,
          duration: const Duration(milliseconds: 140),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _down ? AppColors.pur : rgba(255, 255, 255, .7),
                  border: Border.all(color: AppColors.pur, width: 2),
                ),
                child: Center(
                  child: Icn(Ic.user, size: 22, color: _down ? Colors.white : AppColors.pur),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key, required this.slides, required this.height, required this.onAccount});
  final List<HeroSlide> slides;
  final double height;
  final VoidCallback onAccount;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final _pc = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // slides forward forever (the PageView is unbounded and wraps by index % n)
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pc.hasClients && _pc.position.hasViewportDimension) {
        _pc.nextPage(
          duration: const Duration(milliseconds: 900),
          curve: const Cubic(0.6, 0.05, 0.25, 1),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final n = widget.slides.length;
    final h1 = (mq.size.width * 0.07).clamp(35.2, 54.4).toDouble();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFFF3D3E7)),
            PageView.builder(
              controller: _pc,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                final s = widget.slides[i % n];
                return Photo(src: s.image, alt: s.name);
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    rgba(255, 255, 255, .72),
                    rgba(255, 255, 255, .5),
                    rgba(255, 255, 255, .88),
                  ],
                  stops: const [0, .45, 1],
                ),
              ),
            ),
            Positioned(
              top: math.max(14.0, mq.padding.top),
              right: 16,
              child: AccountButton(onTap: widget.onAccount),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TARA ILOILO | Iloilo discovery',
                    style: jost(size: 12.48, weight: FontWeight.w600, letterSpacing: 1.0, color: AppColors.pur),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explore Iloilo',
                    style: jost(size: h1, weight: FontWeight.w700, height: 1.05, color: AppColors.deep),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Heritage streets, local flavors.\nFind your way through Iloilo.',
                    style: jost(size: 16, height: 1.45, color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------------------------------------------- Search */

class DiscoverSearch extends StatefulWidget {
  const DiscoverSearch({
    super.key,
    required this.onOpen,
    required this.onOpenChange,
    required this.openWidth,
  });

  final ValueChanged<ContentItem> onOpen;
  final ValueChanged<bool> onOpenChange;
  final double openWidth;

  @override
  State<DiscoverSearch> createState() => _DiscoverSearchState();
}

class _DiscoverSearchState extends State<DiscoverSearch> {
  final _q = TextEditingController();
  final _focus = FocusNode();
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  bool _lastOpen = false;

  bool get _open => _focus.hasFocus || _q.text.isNotEmpty;
  List<ContentItem> get _results => _q.text.trim().isEmpty ? const [] : searchContent(_q.text);

  @override
  void initState() {
    super.initState();
    _focus.addListener(_sync);
    _q.addListener(_sync);
  }

  @override
  void dispose() {
    _focus.removeListener(_sync);
    _q.removeListener(_sync);
    _focus.dispose();
    _q.dispose();
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    setState(() {});
    final open = _open;
    if (open != _lastOpen) {
      _lastOpen = open;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onOpenChange(open);
      });
    }
    final showList = open && _q.text.trim().isNotEmpty;
    if (showList && !_portal.isShowing) {
      _portal.show();
    } else if (!showList && _portal.isShowing) {
      _portal.hide();
    }
  }

  void _pick(ContentItem? r) {
    if (r != null && r.type != ContentType.event) {
      widget.onOpen(r);
      _q.clear();
      _focus.unfocus();
    }
  }

  String _typeLabel(ContentItem r) => switch (r.type) {
        ContentType.event => 'Event',
        ContentType.food => 'Local Food',
        ContentType.landmark => 'Landmark',
      };

  Widget _buildList(BuildContext context) {
    final results = _results;
    return Positioned(
      left: 0,
      top: 0,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(0, 8),
        child: TextFieldTapRegion(
          child: SizedBox(
            width: widget.openWidth,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 260),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.lite, width: 1),
                boxShadow: [
                  BoxShadow(color: rgba(121, 32, 94, .2), blurRadius: 30, offset: const Offset(0, 14)),
                ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: results.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Text('No matches yet', style: jost(size: 14.4, color: AppColors.soft)),
                      )
                    : ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          for (final r in results)
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _pick(r),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        r.name,
                                        style: jost(size: 14.72, weight: FontWeight.w700, color: const Color(0xFF222222)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(_typeLabel(r), style: jost(size: 12.48, color: AppColors.pur)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final open = _open;
    final results = _results;
    final hasQ = _q.text.isNotEmpty;
    final inputRight = 8.0 + (hasQ ? 40 : 0) + (results.isNotEmpty ? 52 : 0);
    final phone = MediaQuery.sizeOf(context).width <= 640;

    return TextFieldTapRegion(
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildList,
        child: CompositedTransformTarget(
          link: _link,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _focus.requestFocus(),
            child: AnimatedContainer(
              duration: Duration(milliseconds: phone ? 450 : 1000),
              curve: const Cubic(0.2, 0.8, 0.2, 1),
              width: open ? widget.openWidth : 50,
              height: 50,
              decoration: BoxDecoration(
                color: rgba(255, 255, 255, .9),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.lite, width: 1.5),
                boxShadow: [
                  BoxShadow(color: rgba(165, 70, 136, .2), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: LayoutBuilder(builder: (context, c) {
                final inputW = math.max(0.0, c.maxWidth - 44 - inputRight);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      width: 47,
                      height: 47,
                      child: Center(child: Icn(Ic.search, size: 22, color: AppColors.pur)),
                    ),
                    Positioned(
                      left: 44,
                      top: 0,
                      width: inputW,
                      height: 47,
                      child: IgnorePointer(
                        ignoring: !open,
                        child: AnimatedOpacity(
                          opacity: open ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: _q,
                              focusNode: _focus,
                              textInputAction: TextInputAction.search,
                              cursorColor: AppColors.pur,
                              style: jost(size: 16, weight: FontWeight.w500, color: const Color(0xFF222222)),
                              onTapOutside: (_) => _focus.unfocus(),
                              onSubmitted: (_) {
                                final r = _results;
                                _pick(r.isEmpty ? null : r.first);
                              },
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Discover',
                                hintStyle: jost(size: 16, weight: FontWeight.w500, color: const Color(0xFF8A8A8A)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (hasQ)
                      Positioned(
                        right: results.isNotEmpty ? 56 : 8,
                        top: 9,
                        width: 28,
                        height: 28,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _q.clear();
                            _focus.requestFocus();
                          },
                          child: Container(
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF4E3EE)),
                            child: Center(child: Icn(Ic.close, size: 16, color: AppColors.deep)),
                          ),
                        ),
                      ),
                    if (results.isNotEmpty)
                      Positioned(
                        right: 5,
                        top: 5,
                        height: 37,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _pick(results.first),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.deep,
                              borderRadius: BorderRadius.circular(19),
                            ),
                            child: Text('Go', style: jost(size: 16, weight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------------------------------------------- Ask TATA / shortcuts */

class AskTata extends StatelessWidget {
  const AskTata({super.key, this.compact = false, this.onPressed});
  final bool compact; // icon only (small phones while searching)
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      label: 'Ask TATA',
      color: GlassColor.deep,
      askStyle: true,
      width: compact ? 50 : 150,
      minWidth: 0,
      minHeight: 50,
      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 14),
      fontSize: 16.8,
      fontWeight: FontWeight.w600,
      gap: 8,
      showLabel: !compact,
      leadingBuilder: (_) => tataImage(36),
      onPressed: onPressed,
    );
  }
}

class ShortcutTile extends StatefulWidget {
  const ShortcutTile({super.key, required this.svg, required this.label, required this.active, required this.onTap});
  final String svg;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<ShortcutTile> createState() => _ShortcutTileState();
}

class _ShortcutTileState extends State<ShortcutTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? Colors.white : AppColors.pur;
    return Semantics(
      button: true,
      selected: widget.active,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.94 : 1,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
            decoration: BoxDecoration(
              color: widget.active ? AppColors.pur : rgba(255, 255, 255, .75),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.active ? AppColors.pur : rgba(205, 123, 180, .6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(color: rgba(165, 70, 136, .12), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: color),
                  duration: const Duration(milliseconds: 300),
                  builder: (_, c, __) => Icn(widget.svg, size: 26, color: c ?? color),
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: jost(size: 13.12, weight: FontWeight.w600, color: color),
                  child: Text(widget.label, textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ----------------------------------------------------------- FloatingTata */

/// Appears at the right edge once the top Ask TATA button scrolls out of view.
/// Swipe it right (or tap the x) to dismiss until the top button is seen again.
class FloatingTata extends StatefulWidget {
  const FloatingTata({
    super.key,
    this.targetKey,
    this.scroll,
    required this.enabled,
    this.onTap,
  });

  /// Home: the top Ask TATA button. The floating button appears once it scrolls out of view.
  /// Leave null (detail pages) to show the button whenever [enabled].
  final GlobalKey? targetKey;
  final ScrollController? scroll;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  State<FloatingTata> createState() => _FloatingTataState();
}

class _FloatingTataState extends State<FloatingTata> {
  bool _away = false;
  bool _ready = false; // always-show mode: flips true after the first frame so it slides in
  bool _dismissed = false;
  bool _dragging = false;
  double _dx = 0;
  double _start = 0;

  bool get _alwaysShow => widget.targetKey == null;

  @override
  void initState() {
    super.initState();
    widget.scroll?.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_alwaysShow) {
        setState(() => _ready = true);
      } else {
        _check();
      }
    });
  }

  @override
  void didUpdateWidget(covariant FloatingTata old) {
    super.didUpdateWidget(old);
    if (!old.enabled && widget.enabled && !_alwaysShow) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  @override
  void dispose() {
    widget.scroll?.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (!mounted || !widget.enabled || _alwaysShow) return;
    final ctx = widget.targetKey!.currentContext;
    if (ctx == null) return;
    final ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return;
    final top = ro.localToGlobal(Offset.zero).dy;
    final bottom = top + ro.size.height;
    final screenH = MediaQuery.sizeOf(context).height;
    final intersecting = bottom > 0 && top < screenH;
    final away = !intersecting && top < 0;
    if (away != _away || (intersecting && (_dismissed || _dx != 0))) {
      setState(() {
        _away = away;
        if (intersecting) {
          _dismissed = false;
          _dx = 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _alwaysShow ? _ready : _away;
    final show = widget.enabled && visible && !_dismissed;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      right: 10,
      bottom: 98 + bottomInset,
      child: IgnorePointer(
        ignoring: !show,
        child: AnimatedOpacity(
          opacity: show ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            duration: _dragging ? Duration.zero : const Duration(milliseconds: 450),
            curve: kEase,
            transform: Matrix4.translationValues(show ? _dx : 146, 0, 0),
            child: GestureDetector(
              onHorizontalDragStart: (d) {
                _start = d.globalPosition.dx;
                setState(() => _dragging = true);
              },
              onHorizontalDragUpdate: (d) =>
                  setState(() => _dx = math.max(0.0, d.globalPosition.dx - _start)),
              onHorizontalDragEnd: (_) => _endDrag(),
              onHorizontalDragCancel: _endDrag,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _dismissed = true),
                    child: Semantics(
                      button: true,
                      label: 'Dismiss TATA',
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: rgba(0, 0, 0, .2), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Center(child: Icn(Ic.close, size: 14, color: AppColors.deep)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Semantics(
                    button: true,
                    label: 'Ask TATA',
                    child: GestureDetector(
                      onTap: widget.onTap,
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: rgba(205, 123, 180, .55),
                              border: Border.all(color: rgba(255, 255, 255, .85), width: 1.5),
                            ),
                            child: Center(child: tataImage(38)),
                          ),
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

  void _endDrag() {
    setState(() {
      _dragging = false;
      if (_dx > 50) {
        _dismissed = true;
      } else {
        _dx = 0;
      }
    });
  }
}

/* -------------------------------------------------------------- BottomNav */

class _NavItem {
  const _NavItem(this.id, this.label, this.svg);
  final String id;
  final String label;
  final String svg;
}

final List<_NavItem> _navItems = [
  _NavItem('home', 'Home', Ic.home),
  _NavItem('dining', 'Dining', Ic.dining),
  _NavItem('map', 'Map', Ic.map),
  _NavItem('language', 'Language', Ic.language),
  _NavItem('events', 'Events', Ic.events),
];

/// Moving-ball nav: ball grows, shrinks, glides across, then expands at the new item.
class BottomNav extends StatefulWidget {
  const BottomNav({super.key, required this.active, required this.onSelect});
  final String active;
  final ValueChanged<String> onSelect;

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  String? _shown;
  late int _pos;
  double _scale = 1;
  List<Timer> _timers = [];
  late String _target;

  int _idx(String id) => _navItems.indexWhere((n) => n.id == id);

  @override
  void initState() {
    super.initState();
    _shown = widget.active;
    _pos = _idx(widget.active);
    _target = widget.active;
  }

  @override
  void didUpdateWidget(covariant BottomNav old) {
    super.didUpdateWidget(old);
    if (widget.active != _target) {
      final id = widget.active;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && id != _target) _animateTo(id);
      });
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  void _animateTo(String id) {
    _target = id;
    for (final t in _timers) {
      t.cancel();
    }
    setState(() {
      _shown = null;
      _scale = 1.18;
    });
    _timers = [
      Timer(const Duration(milliseconds: 130), () {
        if (mounted) setState(() => _scale = 0.35);
      }),
      Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _pos = _idx(id));
      }),
      Timer(const Duration(milliseconds: 760), () {
        if (mounted) {
          setState(() {
            _scale = 1;
            _shown = id;
          });
        }
      }),
    ];
  }

  void _choose(String id) {
    widget.onSelect(id);
    if (id != _target) _animateTo(id);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(color: rgba(165, 70, 136, .15), blurRadius: 24, offset: const Offset(0, -6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: 76 + bottom,
            padding: EdgeInsets.fromLTRB(6, 0, 6, bottom),
            decoration: BoxDecoration(
              color: rgba(255, 255, 255, .9),
              border: Border(top: BorderSide(color: rgba(205, 123, 180, .4), width: 1)),
            ),
            child: LayoutBuilder(builder: (context, c) {
              final itemW = c.maxWidth / 5;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 460),
                    curve: const Cubic(0.55, 0.05, 0.25, 1),
                    left: _pos * itemW,
                    top: 6,
                    width: itemW,
                    child: IgnorePointer(
                      child: Center(
                        child: AnimatedScale(
                          scale: _scale,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.4, -0.4),
                                radius: 0.99,
                                colors: [rgba(255, 255, 255, .95), rgba(205, 123, 180, .55)],
                              ),
                              border: Border.all(color: rgba(222, 25, 162, .45), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: rgba(222, 25, 162, .3), blurRadius: 16, offset: const Offset(0, 6)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (final n in _navItems)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _choose(n.id),
                            child: _NavButton(item: n, on: _shown == n.id),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.on});
  final _NavItem item;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final iconColor = on ? AppColors.deep : const Color(0xFF9A8A95);
    return Semantics(
      button: true,
      selected: on,
      label: item.label,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          children: [
            AnimatedScale(
              scale: on ? 1.3 : 1,
              duration: const Duration(milliseconds: 400),
              curve: const Cubic(0.3, 1.5, 0.5, 1),
              child: SizedBox(
                height: 54,
                child: Center(
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: iconColor),
                    duration: const Duration(milliseconds: 300),
                    builder: (_, c, __) => Icn(item.svg, size: 24, color: c ?? iconColor),
                  ),
                ),
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: jost(
                size: 11.2,
                height: 1.2,
                weight: on ? FontWeight.w700 : FontWeight.w500,
                color: on ? AppColors.pur : const Color(0xFF9A8A95),
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
