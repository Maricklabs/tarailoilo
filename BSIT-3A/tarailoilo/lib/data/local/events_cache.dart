import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_event.dart';

/// The last downloaded Supabase events, saved as JSON for offline viewing.
///
/// Simple first version (agreed with the team): SharedPreferences instead of
/// drift. It can move into the drift database later without changing the
/// screens, because they only talk to the events controller.
class EventsCache {
  EventsCache(this._prefs);

  final SharedPreferences _prefs;

  static const _eventsKey = 'events_cache_json';
  static const _savedAtKey = 'events_cache_saved_at';

  /// Saves the events and the time they were downloaded.
  Future<void> save(List<AppEvent> events) async {
    final json = jsonEncode(events.map((e) => e.toJson()).toList());
    await _prefs.setString(_eventsKey, json);
    await _prefs.setString(_savedAtKey, DateTime.now().toIso8601String());
  }

  /// Returns the cached events, or `null` if nothing was saved yet.
  List<AppEvent>? load() {
    final json = _prefs.getString(_eventsKey);
    if (json == null) return null;
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => AppEvent.fromJson(e as Map<String, dynamic>)).toList();
    } on FormatException {
      return null; // Corrupt cache: behave as if empty.
    }
  }

  /// When [save] last ran, or `null`.
  DateTime? get savedAt {
    final raw = _prefs.getString(_savedAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }
}
