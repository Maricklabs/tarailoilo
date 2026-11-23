import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import 'events_theme.dart';

/// Orange header from the Figma design: "← TARA ILO" back link and profile
/// icon on top, then a big white title and an optional yellow subtitle.
class EventsHeader extends StatelessWidget {
  const EventsHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String title;

  /// Yellow line under the title (the event time on S21).
  final String? subtitle;

  /// What "← TARA ILO" does. Defaults to going back, or Home if there is
  /// nothing to go back to (the Events tab root).
  final VoidCallback? onBack;

  /// Extra button next to the title (the calendar/list toggle on S20).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: EventsColors.orange,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 12, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: EventsColors.yellow),
                    onPressed: onBack ??
                        () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
                    icon: const Icon(Icons.arrow_back, size: 20),
                    label: const Text('TARA ILO', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Profile',
                    color: EventsColors.yellow,
                    iconSize: 32,
                    onPressed: () => context.push(AppRoutes.profile),
                    icon: const Icon(Icons.account_circle_outlined),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ?trailing, // added only when not null
                  ],
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    subtitle!,
                    style: textTheme.titleLarge?.copyWith(color: EventsColors.yellow),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
