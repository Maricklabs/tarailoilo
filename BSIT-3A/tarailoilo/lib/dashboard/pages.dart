import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/anim.dart';
import '../widgets/element_design.dart';
import 'components.dart';
import 'content.dart';
import 'detail_parts.dart';
import 'icons.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.scroll,
    required this.askKey,
    required this.onOpen,
    required this.onAccount,
    required this.onSeeAll,
  });

  final ScrollController scroll;
  final GlobalKey askKey;
  final ValueChanged<ContentItem> onOpen;
  final VoidCallback onAccount;
  final VoidCallback onSeeAll;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _sel;
  bool _searching = false;

  void _toggle(String k) => setState(() => _sel = _sel == k ? null : k);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final heroH = (mq.size.height * 0.48).clamp(300.0, 460.0).toDouble();
    final rowW = screenW - 32;
    final small = screenW <= 520;
    final openW = small ? rowW - 62 : math.min(rowW - 162, 440.0);
    final compactAsk = small && _searching;

    return SingleChildScrollView(
      controller: widget.scroll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // hero + search row (the row overlaps the hero by 28px)
          SizedBox(
            height: heroH + 22,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: heroH,
                  child: HeroCarousel(slides: kHeroSlides, height: heroH, onAccount: widget.onAccount),
                ),
                Positioned(
                  top: heroH - 28,
                  left: 16,
                  right: 16,
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DiscoverSearch(
                        onOpen: widget.onOpen,
                        onOpenChange: (v) => setState(() => _searching = v),
                        openWidth: openW,
                      ),
                      const Spacer(),
                      Container(key: widget.askKey, child: AskTata(compact: compactAsk)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // shortcuts
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: ShortcutTile(svg: Ic.camera, label: 'TARA LENS', active: _sel == 'lens', onTap: () => _toggle('lens'))),
                  const SizedBox(width: 12),
                  Expanded(child: ShortcutTile(svg: Ic.route, label: 'My Journey', active: _sel == 'journey', onTap: () => _toggle('journey'))),
                  const SizedBox(width: 12),
                  Expanded(child: ShortcutTile(svg: Ic.language, label: 'Phrasebook', active: _sel == 'phrase', onTap: () => _toggle('phrase'))),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
            child: Collection(title: 'Landmarks', items: kLandmarks, onOpen: widget.onOpen),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
            child: Collection(title: 'Local Food', items: kFoods, onOpen: widget.onOpen),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ongoing Events', style: jost(size: 22.4, weight: FontWeight.w600, color: AppColors.pur)),
                const SizedBox(height: 14),
                for (var i = 0; i < kEvents.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  Entrance(
                    delay: Duration(milliseconds: i * 60),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.ease,
                    from: const Offset(0, 12),
                    child: EventCard(item: kEvents[i]),
                  ),
                ],
                const SizedBox(height: 14),
                Center(
                  child: GlassButton(
                    label: 'See All',
                    color: GlassColor.deep,
                    fit: true,
                    onPressed: widget.onSeeAll,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 110 + mq.padding.bottom),
        ],
      ),
    );
  }
}

class Detail extends StatefulWidget {
  const Detail({super.key, required this.item, required this.onBack, required this.onOpen});
  final ContentItem item;
  final VoidCallback onBack;
  final ValueChanged<ContentItem> onOpen;

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  final _sc = ScrollController();
  bool _small = false;

  @override
  void initState() {
    super.initState();
    _sc.addListener(() {
      final s = _sc.hasClients && _sc.offset > 40;
      if (s != _small) setState(() => _small = s);
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final related = getRelated(item, item.type == ContentType.food ? 4 : 3);
    final first = item.history.isNotEmpty ? item.history.first : '';
    final rest = item.history.length > 1 ? item.history.sublist(1) : const <String>[];
    return Column(
      children: [
        DetailHeader(item: item, small: _small, onBack: widget.onBack),
        Expanded(
          child: SingleChildScrollView(
            controller: _sc,
            padding: EdgeInsets.fromLTRB(16, 18, 16, 30 + 110 + bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MainImage(item: item),
                HistoricalDescription(title: item.title, paragraph: first),
                for (var k = 0; k < rest.length; k++)
                  PhotoSection(
                    photo: item.gallery.length > k + 1 ? item.gallery[k + 1] : null,
                    paragraph: rest[k],
                  ),
                KeepDiscovering(item: item, related: related, onOpen: widget.onOpen),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty destinations (Account Settings, Events tab) - designed separately.
class Blank extends StatelessWidget {
  const Blank({super.key, required this.name, required this.onBack});
  final String name;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16 + top, 16, 16),
      child: Align(
        alignment: Alignment.topLeft,
        child: RoundBackButton(onTap: onBack),
      ),
    );
  }
}
