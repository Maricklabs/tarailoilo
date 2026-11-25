import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../data/local/events_cache.dart';
import '../../../data/remote/events_service.dart';
import '../../../models/app_event.dart';
import '../data/staple_events.dart';

/// What the Events screens display.
class EventsFeed {
  const EventsFeed({
    required this.events,
    this.offlineNotice,
  });

  /// Staple events + Supabase events, sorted by start date.
  final List<AppEvent> events;

  /// Set when the online events could not be refreshed, e.g.
  /// "Offline: showing events saved on Nov 24, 9:00 AM".
  final String? offlineNotice;

  /// Finds one event by ID (for the detail screen).
  AppEvent? byId(String id) {
    for (final e in events) {
      if (e.id == id) return e;
    }
    return null;
  }
}

final eventsServiceProvider = Provider<EventsService>((ref) => EventsService());

final eventsCacheProvider = Provider<EventsCache>(
  (ref) => EventsCache(ref.watch(sharedPreferencesProvider)),
);

/// Loads the events feed.
///
/// 1. Staple festivals/holidays are always available (offline-first).
/// 2. Try Supabase; on success, save the result to the offline cache.
/// 3. If Supabase fails (offline, timeout, not configured), fall back to
///    the cache and tell the user with [EventsFeed.offlineNotice].
///
/// Pull-to-refresh calls `ref.refresh(eventsFeedProvider.future)`.
final eventsFeedProvider = FutureProvider<EventsFeed>((ref) async {
  final service = ref.read(eventsServiceProvider);
  final cache = ref.read(eventsCacheProvider);
  final now = DateTime.now();
  final staple = StapleEvents.forUpcomingYears(now);

  List<AppEvent> online;
  String? notice;
  try {
    online = await service.fetchEvents(now: now);
    await cache.save(online);
  } catch (_) {
    online = cache.load() ?? const [];
    final savedAt = cache.savedAt;
    notice = savedAt == null
        ? 'Could not load the latest events. Showing yearly Iloilo events only.'
        : 'Offline: showing events saved on ${_shortDate(savedAt)}.';
  }

  final all = [...staple, ...online]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  return EventsFeed(events: all, offlineNotice: notice);
});

String _shortDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  return '${months[d.month - 1]} ${d.day}, $hour:$minute ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// Search text + category filter applied to a list of events.
///
/// Kept as a plain function so it is easy to unit test and to explain.
List<AppEvent> filterEvents(
  List<AppEvent> events, {
  String query = '',
  EventCategory? category,
}) {
  final q = query.trim().toLowerCase();
  return events.where((e) {
    if (category != null && e.category != category) return false;
    if (q.isEmpty) return true;
    return e.title.toLowerCase().contains(q) ||
        (e.venue?.toLowerCase().contains(q) ?? false) ||
        (e.description?.toLowerCase().contains(q) ?? false);
  }).toList();
}

/// Up to [limit] other events in the same category, upcoming first
/// (the "Similar Events" section of S21).
List<AppEvent> similarEvents(List<AppEvent> all, AppEvent event, DateTime now, {int limit = 3}) {
  return all
      .where((e) =>
          e.id != event.id &&
          e.title != event.title && // skip next year's copy of the same staple event
          e.category == event.category &&
          !e.endsAt.isBefore(now))
      .take(limit)
      .toList();
}
