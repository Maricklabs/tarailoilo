// [DELETE] whole file – web preview only
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OfflineMapService {
  OfflineMapService._();
  static final OfflineMapService instance = OfflineMapService._();

  static const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const userAgent = 'com.example.tara_ilo';
  static const minZoom = 12;
  static const maxCachedZoom = 16;

  static final bounds = LatLngBounds(
    const LatLng(10.64, 122.48),
    const LatLng(10.77, 122.62),
  );

  final ValueNotifier<double?> progress = ValueNotifier(null);

  Future<void> ensureInitialised() async {}
  TileProvider tileProvider() => NetworkTileProvider();
  Future<void> downloadWhenOnline() async {}
}
