import '../../../models/app_event.dart';

/// Hardcoded yearly Iloilo festivals and local holidays.
///
/// These never need the internet: the app works out each year's dates from
/// a rule (a fixed date, or "the 4th Sunday of January"). Festivals whose
/// exact dates are set by organizers every year are marked
/// `datesApproximate`, and the UI shows "subject to official schedule".
///
/// TODO(content): have the Iloilo City Tourism Office verify these entries.
abstract final class StapleEvents {
  /// All staple events for [year] and the year after, sorted by start date.
  static List<AppEvent> forUpcomingYears(DateTime now) {
    final events = [..._forYear(now.year), ..._forYear(now.year + 1)];
    events.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return events;
  }

  /// Builds every staple event for one year.
  static List<AppEvent> _forYear(int y) {
    final dinagyangSunday = nthWeekdayOfMonth(y, DateTime.january, DateTime.sunday, 4);
    final parawSaturday = nthWeekdayOfMonth(y, DateTime.february, DateTime.saturday, 3);

    return [
      _event(
        key: 'pasungay',
        year: y,
        title: 'Pasungay Festival',
        category: EventCategory.festival,
        start: nthWeekdayOfMonth(y, DateTime.january, DateTime.saturday, 2),
        venue: 'San Joaquin, Iloilo',
        lat: 10.5913,
        lng: 122.1426,
        approximate: true,
        description:
            'A town festival of San Joaquin, in southern Iloilo, known for its '
            'traditional bull-fighting contest (bulls against bulls) and '
            'merrymaking during the town fiesta season.',
      ),
      _event(
        key: 'kasadyahan',
        year: y,
        title: 'Kasadyahan Festival',
        category: EventCategory.culture,
        start: dinagyangSunday.subtract(const Duration(days: 8)),
        venue: 'Iloilo City Downtown',
        lat: 10.6926,
        lng: 122.5684,
        approximate: true,
        description:
            'Part of the Dinagyang season. Kasadyahan showcases cultural '
            'festivals from towns across Iloilo and Western Visayas through '
            'street dancing and performances.',
      ),
      _event(
        key: 'dinagyang',
        year: y,
        title: 'Dinagyang Festival',
        category: EventCategory.festival,
        start: dinagyangSunday.subtract(const Duration(days: 2)),
        end: dinagyangSunday,
        venue: 'Iloilo City Downtown & Freedom Grandstand',
        lat: 10.6926,
        lng: 122.5684,
        approximate: true,
        description:
            'Iloilo\'s biggest festival, held every fourth weekend of January '
            'in honor of the Santo Niño. It began in the late 1960s, and today '
            'tribes in Ati-inspired costumes perform street dances and '
            'choreographed presentations. The weekend also includes religious '
            'processions and street parties.',
      ),
      _event(
        key: 'jaro-fiesta',
        year: y,
        title: 'Jaro Fiesta (Feast of the Candelaria)',
        category: EventCategory.holiday,
        start: DateTime(y, DateTime.february, 2),
        venue: 'Jaro Metropolitan Cathedral, Jaro',
        lat: 10.7241,
        lng: 122.5579,
        description:
            'Feast of Nuestra Señora de la Candelaria, patroness of Jaro and '
            'Western Visayas. A special non-working day in Iloilo City, '
            'celebrated with masses, a grand procession, and the fiesta queen '
            'tradition.',
      ),
      _event(
        key: 'paraw-regatta',
        year: y,
        title: 'Paraw Regatta Festival',
        category: EventCategory.festival,
        start: parawSaturday,
        end: parawSaturday.add(const Duration(days: 1)),
        venue: 'Villa Arevalo Beach, Iloilo City',
        lat: 10.6870,
        lng: 122.5170,
        approximate: true,
        description:
            'A race of traditional double-outrigger sailboats (paraw) across '
            'the Iloilo Strait between Iloilo and Guimaras. Often called the '
            'oldest traditional sailing event in Asia, it is held every '
            'February with beach activities in Villa Arevalo.',
      ),
      _event(
        key: 'molo-fiesta',
        year: y,
        title: 'Molo Fiesta (Feast of Santa Ana)',
        category: EventCategory.culture,
        start: DateTime(y, DateTime.july, 26),
        venue: 'Molo Church (St. Anne Parish), Molo',
        lat: 10.6974,
        lng: 122.5450,
        description:
            'District fiesta of Molo in honor of its patroness, Saint Anne. '
            'Molo Church is known for its all-female saints along the nave, '
            'and the district is the home of pancit molo.',
      ),
      _event(
        key: 'charter-day',
        year: y,
        title: 'Iloilo City Charter Day',
        category: EventCategory.holiday,
        start: DateTime(y, DateTime.august, 25),
        venue: 'Iloilo City Hall',
        lat: 10.6963,
        lng: 122.5684,
        description:
            'Marks the day Iloilo became a chartered city on August 25, 1937. '
            'A special non-working day in Iloilo City, with civic programs '
            'and city-wide celebrations.',
      ),
      _event(
        key: 'cry-of-santa-barbara',
        year: y,
        title: 'Cry of Santa Barbara',
        category: EventCategory.holiday,
        start: DateTime(y, DateTime.november, 17),
        venue: 'Santa Barbara, Iloilo',
        lat: 10.8231,
        lng: 122.5345,
        description:
            'Commemorates November 17, 1898, when Ilonggo revolutionaries '
            'raised the Philippine flag in Santa Barbara during the '
            'revolution against Spain. Observed as a holiday in Iloilo '
            'province.',
      ),
      _event(
        key: 'simbang-gabi',
        year: y,
        title: 'Simbang Gabi & Christmas in Iloilo',
        category: EventCategory.culture,
        start: DateTime(y, DateTime.december, 16),
        end: DateTime(y, DateTime.december, 24),
        venue: 'Churches across Iloilo',
        lat: 10.6969,
        lng: 122.5644,
        description:
            'Nine days of dawn masses before Christmas, held in parishes '
            'across Iloilo, alongside Christmas lights, food stalls and '
            'holiday events in the city.',
      ),
    ];
  }

  /// Creates one all-day staple event from [start] to the end of [end].
  static AppEvent _event({
    required String key,
    required int year,
    required String title,
    required EventCategory category,
    required DateTime start,
    DateTime? end,
    required String venue,
    required double lat,
    required double lng,
    required String description,
    bool approximate = false,
  }) {
    final lastDay = end ?? start;
    return AppEvent(
      id: 'staple-$key-$year',
      title: title,
      category: category,
      startsAt: DateTime(start.year, start.month, start.day),
      endsAt: DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59),
      venue: venue,
      lat: lat,
      lng: lng,
      description: description,
      source: EventSource.staple,
      allDay: true,
      datesApproximate: approximate,
    );
  }
}

/// The [n]th [weekday] (DateTime.monday..sunday) of [month] in [year].
/// Example: the 4th Sunday of January 2027 is January 24, 2027.
DateTime nthWeekdayOfMonth(int year, int month, int weekday, int n) {
  final first = DateTime(year, month, 1);
  final offset = (weekday - first.weekday + 7) % 7;
  return DateTime(year, month, 1 + offset + (n - 1) * 7);
}
