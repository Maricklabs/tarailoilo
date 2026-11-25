import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/element_design.dart';
import 'components.dart';
import 'content.dart';
import 'icons.dart';

/// Reusable pieces for landmark AND food detail pages. They only read item fields.

/// Round back button used by detail pages and the blank pages.
class RoundBackButton extends StatefulWidget {
  const RoundBackButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<RoundBackButton> createState() => _RoundBackButtonState();
}

class _RoundBackButtonState extends State<RoundBackButton> {
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
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.88 : 1,
          duration: const Duration(milliseconds: 140),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.lite, width: 1.5),
            ),
            child: Center(child: Icn(Ic.back, size: 20, color: AppColors.pur)),
          ),
        ),
      ),
    );
  }
}

class LocateButton extends StatelessWidget {
  const LocateButton({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: wire to the Map screen when it exists
    return GlassButton(
      label: 'Locate in Maps',
      color: GlassColor.pink,
      fit: true,
      minWidth: 0,
      minHeight: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      fontSize: 12.48,
      fontWeight: FontWeight.w700,
      gap: 6,
      leadingBuilder: (c) => Icn(Ic.pin, size: 18, color: c),
    );
  }
}

class DetailHeader extends StatelessWidget {
  const DetailHeader({super.key, required this.item, required this.small, required this.onBack});
  final ContentItem item;
  final bool small;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final v = small ? 8.0 : 12.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.fromLTRB(16, v + top, 16, v),
      decoration: BoxDecoration(
        color: rgba(251, 233, 245, .94),
        border: Border(bottom: BorderSide(color: rgba(205, 123, 180, .35), width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundBackButton(onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!small)
                    Text(
                      'TARA ILOILO',
                      style: jost(size: 11.2, weight: FontWeight.w700, letterSpacing: 0.67, color: AppColors.deep),
                    ),
                  Text(
                    item.name,
                    style: jost(size: 18.4, weight: FontWeight.w600, height: 1.2, color: AppColors.pur),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          const LocateButton(),
        ],
      ),
    );
  }
}

class MainImage extends StatelessWidget {
  const MainImage({super.key, required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Reveal(
      child: Photo(
        src: item.gallery.isNotEmpty ? item.gallery[0].image : item.image,
        alt: item.name,
        natural: true,
        radius: 22,
        aspectRatio: 16 / 9,
      ),
    );
  }
}

class HistoricalDescription extends StatelessWidget {
  const HistoricalDescription({super.key, required this.title, required this.paragraph});
  final String? title;
  final String paragraph;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h2 = (w * 0.04).clamp(24.0, 32.0).toDouble();
    return Reveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 22, bottom: 10),
            child: Text(
              title ?? '',
              style: jost(size: h2, weight: FontWeight.w700, color: AppColors.deep),
            ),
          ),
          Text(paragraph, style: jost(size: 16, height: 1.75, color: AppColors.ink)),
        ],
      ),
    );
  }
}

/// Extra photo + text block.
class PhotoSection extends StatelessWidget {
  const PhotoSection({super.key, required this.photo, required this.paragraph});
  final GalleryPhoto? photo;
  final String paragraph;

  @override
  Widget build(BuildContext context) {
    return Reveal(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photo != null) ...[
              Photo(src: photo!.image, alt: photo!.caption, natural: true, radius: 18, aspectRatio: 4 / 3),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(photo!.caption, style: jost(size: 12.8, color: AppColors.soft)),
              ),
              const SizedBox(height: 14),
            ],
            Text(paragraph, style: jost(size: 16, height: 1.75, color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

/// Food row: thumbnail, name, short description, arrow. Same touchdown -> purple -> open.
class RelatedFoodRow extends StatefulWidget {
  const RelatedFoodRow({super.key, required this.item, required this.onOpen});
  final ContentItem item;
  final ValueChanged<ContentItem> onOpen;

  @override
  State<RelatedFoodRow> createState() => _RelatedFoodRowState();
}

class _RelatedFoodRowState extends State<RelatedFoodRow> {
  bool _on = false;
  bool _down = false;

  Future<void> _go() async {
    if (_on) return;
    setState(() => _on = true);
    await Future.delayed(const Duration(milliseconds: 280));
    widget.onOpen(widget.item);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _on = false);
  }

  @override
  Widget build(BuildContext context) {
    final on = _on;
    return AnimatedScale(
      scale: (on || _down) ? 0.98 : 1,
      duration: const Duration(milliseconds: 160),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: _go,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
          decoration: BoxDecoration(
            color: on ? AppColors.pur : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: on ? AppColors.pur : rgba(205, 123, 180, .55), width: 1.5),
            boxShadow: [
              BoxShadow(color: rgba(165, 70, 136, .12), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Photo(src: widget.item.image, radius: 14),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: jost(size: 16, weight: FontWeight.w600, color: on ? Colors.white : AppColors.deep),
                      child: Text(widget.item.name),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: jost(size: 13.6, height: 1.35, color: on ? Colors.white : AppColors.soft),
                      child: Text(widget.item.short, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: on ? Colors.white : AppColors.pur),
                duration: const Duration(milliseconds: 300),
                builder: (_, c, __) => Icn(Ic.arrow, size: 20, color: c ?? AppColors.pur),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KeepDiscovering extends StatelessWidget {
  const KeepDiscovering({super.key, required this.item, required this.related, required this.onOpen});
  final ContentItem item;
  final List<ContentItem> related;
  final ValueChanged<ContentItem> onOpen;

  @override
  Widget build(BuildContext context) {
    if (related.isEmpty) return const SizedBox.shrink();
    final food = item.type == ContentType.food;
    return Reveal(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Keep discovering', style: jost(size: 24, weight: FontWeight.w600, color: AppColors.pur)),
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 12),
              child: Text(
                food ? 'Related food' : 'Related places',
                style: jost(size: 12.8, color: AppColors.soft),
              ),
            ),
            if (food)
              Column(
                children: [
                  for (var i = 0; i < related.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    RelatedFoodRow(item: related[i], onOpen: onOpen),
                  ],
                ],
              )
            else
              LayoutBuilder(builder: (context, c) {
                // grid of repeat(auto-fill, minmax(150px, 1fr)) with a 14px gap
                final cols = ((c.maxWidth + 14) / (150 + 14)).floor().clamp(1, 3);
                final w = (c.maxWidth - 14 * (cols - 1)) / cols;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final r in related)
                      SizedBox(
                        width: w,
                        child: PressCard(
                          item: r,
                          onOpen: onOpen,
                          extra: [if (r.distance != null) Text(r.distance!)],
                        ),
                      ),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}
