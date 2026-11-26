import 'package:flutter_test/flutter_test.dart';
import 'package:iloilo_tourist_app/core/utils/formatters.dart';
import 'package:iloilo_tourist_app/features/events/controllers/events_controller.dart';
import 'package:iloilo_tourist_app/features/events/data/staple_events.dart';
import 'package:iloilo_tourist_app/models/app_event.dart';

/// Unit tests for the Events feature logic (no UI, no network).
void main() {
  group('nthWeekdayOfMonth', () {
    test('4th Sunday of January (Dinagyang)', () {
      expect(nthWeekdayOfMonth(2027, 1, DateTime.sunday, 4), DateTime(2027, 1, 24));
      expect(nthWeekdayOfMonth(2026, 1, DateTime.sunday, 4), DateTime(2026, 1, 25));
    });

    test('works when the month starts on that weekday', () {
      // February 1, 2026 is a Sunday.
      expect(nthWeekdayOfMonth(2026, 2, DateTime.sunday, 1), DateTime(2026, 2, 1));
    });
  });

  group('StapleEvents', () {
    final events = StapleEvents.forUpcomingYears(DateTime(2026, 11, 24));

    test('covers this year and next year, sorted', () {
      expect(events.where((e) => e.title == 'Dinagyang Festival').length, 2);
      for (var i = 1; i < events.length; i++) {
        expect(events[i - 1].startsAt.isAfter(events[i].startsAt), isFalse);
      }
    });

    test('Dinagyang 2027 is the weekend ending on the 4th Sunday', () {
      final dinagyang = events.firstWhere((e) => e.id == 'staple-dinagyang-2027');
      expect(dinagyang.startsAt, DateTime(2027, 1, 22));
      expect(dinagyang.endsAt.day, 24);
      expect(dinagyang.datesApproximate, isTrue);
    });

    test('fixed holidays keep their date', () {
      final charter = events.firstWhere((e) => e.id == 'staple-charter-day-2027');
      expect(charter.startsAt, DateTime(2027, 8, 25));
      expect(charter.category, EventCategory.holiday);
    });
  });

  group('AppEvent', () {
    final event = AppEvent(
      id: 'x',
      title: 'Food Fair',
      category: EventCategory.food,
      startsAt: DateTime(2026, 12, 4, 10),
      endsAt: DateTime(2026, 12, 6, 21),
      source: EventSource.supabase,
    );

    test('ongoing / upcoming', () {
      expect(event.isUpcoming(DateTime(2026, 12, 1)), isTrue);
      expect(event.isOngoing(DateTime(2026, 12, 5, 12)), isTrue);
      expect(event.isOngoing(DateTime(2026, 12, 7)), isFalse);
    });

    test('occursOn covers every day of a multi-day event', () {
      expect(event.occursOn(DateTime(2026, 12, 4)), isTrue);
      expect(event.occursOn(DateTime(2026, 12, 6)), isTrue);
      expect(event.occursOn(DateTime(2026, 12, 7)), isFalse);
    });

    test('JSON round trip (offline cache)', () {
      final copy = AppEvent.fromJson(event.toJson());
      expect(copy.title, event.title);
      expect(copy.startsAt, event.startsAt);
      expect(copy.category, EventCategory.food);
    });
  });

  test('filterEvents by text and category', () {
    final events = StapleEvents.forUpcomingYears(DateTime(2026, 11, 24));
    expect(filterEvents(events, query: 'paraw').every((e) => e.title.contains('Paraw')), isTrue);
    expect(filterEvents(events, category: EventCategory.holiday).every((e) => e.category == EventCategory.holiday), isTrue);
    expect(filterEvents(events, query: 'no such event'), isEmpty);
  });

  test('formatDateRange', () {
    expect(formatDateRange(DateTime(2027, 1, 4), DateTime(2027, 1, 7)), 'January 4 - 7, 2027');
    expect(formatDateRange(DateTime(2027, 1, 16), DateTime(2027, 1, 16, 22)), 'January 16, 2027');
  });
}
