import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/iloilo_places.dart';

class PassedPlace {
  PassedPlace(this.place, this.at);
  final Place place;
  final DateTime at;
}

/// Foreground location tracking: records the route polyline, detects when the
/// user comes within [geofenceMeters] of a place, notifies and logs it.
/// Singleton so S16 ("Places passed & routes") can read [passed] and [path].
class PlacesTracker extends ChangeNotifier {
  PlacesTracker._();
  static final PlacesTracker instance = PlacesTracker._();

  static const geofenceMeters = 75.0;
  static const _exitMargin = 25.0;
  static const _distance = Distance();

  final List<LatLng> path = [];
  final List<PassedPlace> passed = [];
  LatLng? current;
  bool tracking = false;

  /// Called on each new geofence entry (use it for an in-app banner).
  void Function(Place place)? onPlacePassed;

  final Set<String> _inside = {};
  StreamSubscription<Position>? _sub;

  final _notifications = FlutterLocalNotificationsPlugin();
  bool _notifReady = false;

  Future<void> _initNotifications() async {
    if (kIsWeb) return;
    if (_notifReady) return;
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _notifReady = true;
  }

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied)
      p = await Geolocator.requestPermission();
    return p == LocationPermission.whileInUse || p == LocationPermission.always;
  }

  /// Starts a new route. Returns false if permission/services are unavailable.
  Future<bool> start() async {
    if (tracking) return true;
    if (!await _ensurePermission()) return false;
    await _initNotifications();

    path.clear();
    _inside.clear();
    tracking = true;
    notifyListeners();

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 8, // metres between updates
      ),
    ).listen(_onPosition, onError: (_) => stop());
    return true;
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    tracking = false;
    notifyListeners();
  }

  void _onPosition(Position pos) {
    final here = LatLng(pos.latitude, pos.longitude);
    current = here;
    path.add(here);

    for (final place in kIloiloPlaces) {
      final d = _distance.as(LengthUnit.Meter, here, place.position);
      if (d <= geofenceMeters && _inside.add(place.id)) {
        passed.add(PassedPlace(place, DateTime.now()));
        _notify(place);
        onPlacePassed?.call(place);
      } else if (d > geofenceMeters + _exitMargin) {
        _inside.remove(place.id); // can trigger again on a later visit
      }
    }
    notifyListeners();
  }

  Future<void> _notify(Place place) async {
    if (kIsWeb) return;
    await _notifications.show(
      id: place.id.hashCode & 0x7fffffff,
      title: 'You passed ${place.name}',
      body:
          'Tap to learn more about this ${place.category.label.toLowerCase()} spot.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'places_passed',
          'Places passed',
          channelDescription: 'Alerts when you pass a significant place',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );
  }
}
