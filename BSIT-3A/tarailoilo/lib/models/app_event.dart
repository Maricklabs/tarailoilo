import 'package:flutter/material.dart';

/// Event categories used for filters, icons and the database `category`
/// column. `holiday` is used by the hardcoded Iloilo holidays.
enum EventCategory {
  concert('Concerts', Icons.music_note),
  festival('Festivals', Icons.celebration),
  food('Food', Icons.restaurant),
  culture('Culture', Icons.museum),
  holiday('Holidays', Icons.flag),
  other('Other', Icons.event);

  const EventCategory(this.label, this.icon);

  /// Text shown on filter chips.
  final String label;

  /// Placeholder icon shown instead of a photo.
  final IconData icon;

  /// Reads the database value; unknown values become [other].
  static EventCategory fromName(String? name) => EventCategory.values
      .firstWhere((c) => c.name == name, orElse: () => EventCategory.other);
}

/// Where an event came from.
enum EventSource {
  /// Hardcoded yearly festival/holiday (lib/features/events/data).
  staple,

  /// Row from the Supabase `events` table (manual or AI-found + approved).
  supabase,
}

/// One event shown in the Events tab (S20) and Event Detail (S21).
class AppEvent {
  const AppEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.endsAt,
    required this.source,
    this.description,
    this.venue,
    this.lat,
    this.lng,
    this.organizer,
    this.sourceUrl,
    this.price,
    this.ticketLink,
    this.aiFound = false,
    this.allDay = false,
    this.datesApproximate = false,
  });

  final String id;
  final String title;
  final EventCategory category;
  final DateTime startsAt;
  final DateTime endsAt;
  final EventSource source;
  final String? description;
  final String? venue;
  final double? lat;
  final double? lng;
  final String? organizer;
  final String? sourceUrl;
  final String? price;
  final String? ticketLink;

  /// Found by the events-ingest AI and approved by an admin.
  final bool aiFound;

  /// No specific time (festivals, holidays): show "All day".
  final bool allDay;

  /// Date follows a yearly rule and may move; show "subject to official
  /// schedule" so we never present a guess as fact.
  final bool datesApproximate;

  /// Happening right now.
  bool isOngoing(DateTime now) => !startsAt.isAfter(now) && !endsAt.isBefore(now);

  /// Starts in the future.
  bool isUpcoming(DateTime now) => startsAt.isAfter(now);

  /// Does the event cover this calendar day (used by the month view)?
  bool occursOn(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return startsAt.isBefore(dayEnd) && !endsAt.isBefore(dayStart);
  }

  /// Builds an event from a Supabase `events` row (or the offline cache).
  factory AppEvent.fromJson(Map<String, dynamic> json) {
    final start = DateTime.parse(json['starts_at'] as String).toLocal();
    final endRaw = json['ends_at'] as String?;
    return AppEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: EventCategory.fromName(json['category'] as String?),
      startsAt: start,
      endsAt: endRaw == null
          ? start.add(const Duration(hours: 3))
          : DateTime.parse(endRaw).toLocal(),
      venue: json['venue'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      organizer: json['organizer'] as String?,
      sourceUrl: json['source_url'] as String?,
      price: json['price'] as String?,
      ticketLink: json['ticket_link'] as String?,
      aiFound: json['ai_found'] as bool? ?? false,
      source: EventSource.supabase,
    );
  }

  /// Same shape as a Supabase row, so the cache can reuse [AppEvent.fromJson].
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'starts_at': startsAt.toUtc().toIso8601String(),
        'ends_at': endsAt.toUtc().toIso8601String(),
        'venue': venue,
        'lat': lat,
        'lng': lng,
        'organizer': organizer,
        'source_url': sourceUrl,
        'price': price,
        'ticket_link': ticketLink,
        'ai_found': aiFound,
      };
}
