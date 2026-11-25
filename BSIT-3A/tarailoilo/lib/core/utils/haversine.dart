import 'dart:math' as math;

/// Distance in meters between two GPS points using the haversine formula.
///
/// Used by geofencing (S14), "nearby landmarks" (S4) and recommendations (S5).
double haversineMeters(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusM = 6371000.0;
  double toRad(double deg) => deg * math.pi / 180;

  final dLat = toRad(lat2 - lat1);
  final dLng = toRad(lng2 - lng1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(toRad(lat1)) * math.cos(toRad(lat2)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * earthRadiusM * math.asin(math.sqrt(a));
}
