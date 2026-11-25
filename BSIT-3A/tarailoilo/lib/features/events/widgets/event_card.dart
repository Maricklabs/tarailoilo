import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../models/app_event.dart';
import 'events_theme.dart';

/// Square category tile used where the Figma design shows a photo.
///
/// Placeholder until the team has photos it is allowed to use (scraped
/// Facebook images must not be reposted).
class EventImagePlaceholder extends StatelessWidget {
  const EventImagePlaceholder({super.key, required this.category, this.size = 110, this.iconSize = 44});

  final EventCategory category;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: EventsColors.orange.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(category.icon, size: iconSize, color: EventsColors.orange),
    );
  }
}

/// Small badge shown on events found by the AI pipeline (spec S20).
class AiFoundBadge extends StatelessWidget {
  const AiFoundBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'AI-found, admin-verified',
        style: TextStyle(fontSize: 10, color: Colors.deepPurple.shade700, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// One event row in the Figma style: image on the left, then title, dates,
/// time, venue and "Details.....".
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.onTap});

  final AppEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final body = textTheme.bodySmall?.copyWith(color: EventsColors.cardTitle);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: EventsColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventImagePlaceholder(category: event.category),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: EventsColors.cardTitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(formatDateRange(event.startsAt, event.endsAt), style: body),
                    Text(
                      event.allDay
                          ? (event.datesApproximate ? 'All day · subject to official schedule' : 'All day')
                          : formatTimeRange(event.startsAt, event.endsAt),
                      style: body,
                    ),
                    Text(event.venue ?? 'TBA', maxLines: 1, overflow: TextOverflow.ellipsis, style: body),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('Details.....', style: body),
                        const Spacer(),
                        if (event.aiFound) const AiFoundBadge(),
                      ],
                    ),
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
