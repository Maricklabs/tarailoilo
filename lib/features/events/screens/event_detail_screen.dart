import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haversine.dart';
import '../../../models/app_event.dart';
import '../../../widgets/state_views.dart';
import '../controllers/events_controller.dart';
import '../widgets/event_card.dart';
import '../widgets/events_header.dart';
import '../widgets/events_theme.dart';

/// S21 Event Detail.
///
/// Follows the Figma "Event Details" frame: orange header with the title and
/// time, a large image, the orange location pill with distance, the History
/// / About text, and Similar Events. Also shows what the spec asks for:
/// organizer, source link, and the AI-found badge.
///
/// TODO(events): closures on the map, "Remind me" and area alerts (S21),
/// and Dinagyang festival mode.
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  /// ID taken from the route path (`/events/:id`).
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(eventsFeedProvider);

    return EventsTheme(
      child: switch (feed) {
        AsyncData(:final value) => switch (value.byId(eventId)) {
            final AppEvent event => _EventDetailView(event: event, allEvents: value.events),
            null => const _Message(
                child: EmptyView(message: 'This event is no longer available.', icon: Icons.event_busy),
              ),
          },
        AsyncError(:final error) => _Message(
            child: ErrorView(
              message: 'Could not load this event.\n$error',
              onRetry: () => ref.invalidate(eventsFeedProvider),
            ),
          ),
        _ => const _Message(child: LoadingView()),
      },
    );
  }
}

/// Header + a centered state view (loading, empty, error).
class _Message extends StatelessWidget {
  const _Message({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const EventsHeader(title: 'Event'),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _EventDetailView extends StatelessWidget {
  const _EventDetailView({required this.event, required this.allEvents});

  final AppEvent event;
  final List<AppEvent> allEvents;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final similar = similarEvents(allEvents, event, DateTime.now());
    final timeText = event.allDay ? 'All day' : formatTimeRange(event.startsAt, event.endsAt);

    return Scaffold(
      body: Column(
        children: [
          EventsHeader(title: event.title, subtitle: timeText),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: EventImagePlaceholder(category: event.category, size: double.infinity, iconSize: 96),
                  ),
                ),
                const SizedBox(height: 14),
                _LocationPill(event: event),
                const SizedBox(height: 14),
                _InfoRow(Icons.calendar_today, formatDateRange(event.startsAt, event.endsAt)),
                if (event.datesApproximate)
                  const _InfoRow(Icons.info_outline,
                      'Dates follow the usual yearly schedule and are subject to the official announcement.'),
                if (event.organizer != null) _InfoRow(Icons.groups_outlined, event.organizer!),
                if (event.price != null) _InfoRow(Icons.confirmation_number_outlined, event.price!),
                if (event.aiFound) ...[
                  const SizedBox(height: 8),
                  const Row(children: [AiFoundBadge()]),
                  const SizedBox(height: 4),
                  Text(
                    'Found by AI from a public post and checked by an admin. '
                    'Details can change, so check the source.',
                    style: textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  event.source == EventSource.staple ? 'History' : 'About',
                  style: textTheme.titleLarge?.copyWith(
                    color: EventsColors.crimson,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(event.description ?? 'No description yet.', style: textTheme.bodyMedium),
                if (event.ticketLink != null || event.sourceUrl != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (event.ticketLink != null)
                        FilledButton.icon(
                          onPressed: () => _openLink(context, event.ticketLink!),
                          icon: const Icon(Icons.local_activity),
                          label: const Text('Tickets'),
                        ),
                      if (event.sourceUrl != null)
                        OutlinedButton.icon(
                          onPressed: () => _openLink(context, event.sourceUrl!),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('View source'),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Text('Similar Events', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (similar.isEmpty)
                  const Text('No similar events right now.')
                else
                  for (final e in similar)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: EventImagePlaceholder(category: e.category, size: 56, iconSize: 26),
                      title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(formatDateRange(e.startsAt, e.endsAt)),
                      trailing: const Icon(Icons.chevron_right, color: EventsColors.orange),
                      onTap: () => context.push(AppRoutes.event(e.id)),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens a link in the browser; shows a message if that fails.
  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    final ok = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the link.')));
    }
  }
}

/// Icon + text line (date, organizer, price).
class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: EventsColors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Orange pill: "📍 Venue • 10 km from your location".
///
/// Location is only read if the user allows it (tap to ask). We only use it
/// on the device to compute the distance; it is never uploaded (RA 10173).
class _LocationPill extends StatefulWidget {
  const _LocationPill({required this.event});

  final AppEvent event;

  @override
  State<_LocationPill> createState() => _LocationPillState();
}

class _LocationPillState extends State<_LocationPill> {
  String? _distance;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadDistance(askPermission: false);
  }

  /// Computes the distance. Asks for permission only when the user taps.
  Future<void> _loadDistance({required bool askPermission}) async {
    final e = widget.event;
    if (e.lat == null || e.lng == null) return;
    setState(() => _loading = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && askPermission) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
        ).timeout(const Duration(seconds: 10));
        final meters = haversineMeters(pos.latitude, pos.longitude, e.lat!, e.lng!);
        _distance = '${formatDistance(meters)} from your location';
      }
    } catch (_) {
      // Location off or timed out: just show the venue.
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final canMeasure = e.lat != null && e.lng != null;
    return Material(
      color: EventsColors.orange,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: canMeasure && _distance == null && !_loading
            ? () => _loadDistance(askPermission: true)
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: e.venue ?? 'Venue TBA',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      if (canMeasure)
                        TextSpan(
                          text: ' • ${_loading ? 'Finding distance...' : _distance ?? 'Tap to see distance'}',
                          style: const TextStyle(color: EventsColors.yellow),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
