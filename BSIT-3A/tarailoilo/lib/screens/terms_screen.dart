import 'package:flutter/material.dart';
import '../dashboard/detail_parts.dart' show RoundBackButton;
import '../data/terms_content.dart';
import '../services/terms_acceptance.dart';
import '../theme.dart';
import '../widgets/element_design.dart';

const double _kMaxWidth = 560; // comfortable reading width on tablets / large screens
const double _kPad = 20;

/// Two connected pages: 1 "Using Tara Ilo" and 2 "Your rights & responsibilities".
/// Shown on top of the screen it was opened from, so Back / Agree return there
/// with everything the user typed still in place.
class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key, required this.onClose});

  /// Closes the Terms screen and returns to the screen underneath.
  final VoidCallback onClose;

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  int _page = 0;
  bool _forward = true;

  // Page 2 -> page 1, page 1 -> back to the screen that opened the terms.
  void _back() {
    if (_page > 0) {
      setState(() {
        _forward = false;
        _page -= 1;
      });
    } else {
      widget.onClose();
    }
  }

  // Continue only moves to the next page. It does NOT accept the terms.
  void _next() => setState(() {
        _forward = true;
        _page += 1;
      });

  // Agree records acceptance (shared state ticks every Terms checkbox) and returns.
  void _agree() {
    termsAcceptance.accept();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final total = kTermsPages.length;
    final data = kTermsPages[_page];
    return PopScope(
      canPop: false, // the Android back button behaves like the on-screen arrow
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            TermsHeader(subtitle: data.subtitle, onBack: _back),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (current, previous) => Stack(
                  fit: StackFit.expand,
                  children: [...previous, if (current != null) current],
                ),
                transitionBuilder: (child, animation) {
                  // new page slides in from the side it is heading to; the old one leaves the other way
                  final incoming = child.key == ValueKey<int>(_page);
                  final dx = (incoming == _forward) ? 0.08 : -0.08;
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _TermsPageView(
                  key: ValueKey<int>(_page),
                  data: data,
                  index: _page,
                  total: total,
                  onContinue: _next,
                  onAgree: _agree,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Light pink header: back arrow + branding, heading, and the page subtitle.
class TermsHeader extends StatelessWidget {
  const TermsHeader({super.key, required this.subtitle, required this.onBack});
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final headingSize = (mq.size.width * 0.07).clamp(26.0, 34.0).toDouble();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(_kPad, 12 + mq.padding.top, _kPad, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9F5),
        border: Border(bottom: BorderSide(color: rgba(205, 123, 180, .35), width: 1)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RoundBackButton(onTap: onBack),
                  const SizedBox(width: 12),
                  Image.asset(
                    assetImg('logo'),
                    height: 30,
                    semanticLabel: 'TARA ILOILO',
                    errorBuilder: (_, __, ___) => Text(
                      'TARA ILOILO',
                      style: jost(size: 16, weight: FontWeight.w700, letterSpacing: 0.9, color: AppColors.deep),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                kTermsHeading,
                style: jost(size: headingSize, weight: FontWeight.w700, height: 1.1, color: AppColors.deep),
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topLeft,
                  children: [...previous, if (current != null) current],
                ),
                child: Text(
                  subtitle,
                  key: ValueKey<String>(subtitle),
                  style: jost(size: 13.12, weight: FontWeight.w600, letterSpacing: 0.4, color: AppColors.pur),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsPageView extends StatelessWidget {
  const _TermsPageView({
    super.key,
    required this.data,
    required this.index,
    required this.total,
    required this.onContinue,
    required this.onAgree,
  });

  final TermsPage data;
  final int index;
  final int total;
  final VoidCallback onContinue;
  final VoidCallback onAgree;

  @override
  Widget build(BuildContext context) {
    final isLast = index == total - 1;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(_kPad, 24, _kPad, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _kMaxWidth),
                child: TermsContent(data: data),
              ),
            ),
          ),
        ),
        TermsFooter(
          note: data.footerNote,
          index: index,
          total: total,
          button: isLast
              ? TermsAgreeButton(label: data.actionLabel, onPressed: onAgree)
              : TermsContinueButton(label: data.actionLabel, onPressed: onContinue),
        ),
      ],
    );
  }
}

/// Everything in the scrolling area of one page: intro, numbered sections, closing lines.
class TermsContent extends StatelessWidget {
  const TermsContent({super.key, required this.data});
  final TermsPage data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.intro.isNotEmpty) ...[
          ..._blocks(data.intro),
          const SizedBox(height: 10),
        ],
        for (var i = 0; i < data.sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          Text(
            '${data.sections[i].number}. ${data.sections[i].title}',
            style: jost(size: 18, weight: FontWeight.w700, height: 1.25, color: AppColors.pur),
          ),
          const SizedBox(height: 8),
          ..._blocks(data.sections[i].blocks),
        ],
        if (data.outro.isNotEmpty) ...[
          const SizedBox(height: 22),
          Center(
            child: Column(
              children: [
                for (final b in data.outro)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      b.text,
                      textAlign: TextAlign.center,
                      style: b.type == TermsBlockType.subheading
                          ? jost(size: 16, weight: FontWeight.w700, height: 1.4, color: AppColors.deep)
                          : jost(size: 15.2, weight: FontWeight.w500, height: 1.5, color: AppColors.soft),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _blocks(List<TermsBlock> blocks) => [
        for (final b in blocks)
          switch (b.type) {
            TermsBlockType.paragraph => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(b.text, style: jost(size: 15.2, height: 1.65, color: AppColors.ink)),
              ),
            TermsBlockType.subheading => Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Text(
                  b.text,
                  style: jost(size: 15.2, weight: FontWeight.w700, height: 1.4, color: AppColors.deep),
                ),
              ),
            TermsBlockType.bullets => Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in b.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 9, right: 12),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.pur),
                              ),
                            ),
                            Expanded(
                              child: Text(item, style: jost(size: 15.2, height: 1.55, color: AppColors.ink)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          },
      ];
}

/// Bottom action area: divider, note, full-width button, "1 / 2".
class TermsFooter extends StatelessWidget {
  const TermsFooter({
    super.key,
    required this.note,
    required this.button,
    required this.index,
    required this.total,
  });

  final String note;
  final Widget button;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(_kPad, 16, _kPad, 14 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: rgba(205, 123, 180, .35), width: 1)),
        boxShadow: [
          BoxShadow(color: rgba(165, 70, 136, .08), blurRadius: 18, offset: const Offset(0, -6)),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                note,
                textAlign: TextAlign.center,
                style: jost(size: 13.6, color: AppColors.soft),
              ),
              const SizedBox(height: 12),
              button,
              const SizedBox(height: 10),
              TermsPageIndicator(index: index, total: total),
            ],
          ),
        ),
      ),
    );
  }
}

/// "1 / 2"
class TermsPageIndicator extends StatelessWidget {
  const TermsPageIndicator({super.key, required this.index, required this.total});
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${index + 1} / $total',
      style: jost(size: 13.12, weight: FontWeight.w600, color: AppColors.pur),
    );
  }
}

/// Page 1 button. Glass -> solid on touch, then moves to page 2 (does not accept).
class TermsContinueButton extends StatelessWidget {
  const TermsContinueButton({super.key, required this.onPressed, this.label = 'Continue'});
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassButton(label: label, color: GlassColor.purple, onPressed: onPressed);
  }
}

/// Page 2 button. Glass -> solid on touch, then records acceptance and returns.
class TermsAgreeButton extends StatelessWidget {
  const TermsAgreeButton({super.key, required this.onPressed, this.label = 'Agree'});
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassButton(label: label, color: GlassColor.purple, onPressed: onPressed);
  }
}
