import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Caches Iloilo map tiles on-device the first time there is internet,
/// then serves them from disk so the map works fully offline.
class OfflineMapService {
  OfflineMapService._();
  static final OfflineMapService instance = OfflineMapService._();

  static const _storeName = 'iloilo_map';
  static const _doneKey = 'iloilo_tiles_downloaded_v1';

  /// Swap for your own tile server / MBTiles-backed source in production.
  /// NOTE: OSM's public tile servers discourage bulk downloads – keep the
  /// zoom range small (as below) or use a provider that allows caching.
  static const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const userAgent = 'com.example.tara_ilo'; // TODO: your package name

  static const minZoom = 12;
  static const maxCachedZoom = 16;

  static final bounds = LatLngBounds(
    const LatLng(10.64, 122.48),
    const LatLng(10.77, 122.62),
  );

  /// null = idle, 0..100 = downloading.
  final ValueNotifier<double?> progress = ValueNotifier(null);

  Future<void>? _init;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _downloading = false;

  Future<void> ensureInitialised() => _init ??= () async {
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore(_storeName).manage.create();
  }();

  FMTCTileProvider tileProvider() =>
      const FMTCStore(_storeName).getTileProvider(
        settings: FMTCTileProviderSettings(
          behavior: CacheBehavior.cacheFirst,
          cachedValidDuration: Duration(days: 365),
        ),
      );

  /// Call once when the map opens. Downloads now if online, otherwise waits
  /// until a connection appears.
  Future<void> downloadWhenOnline() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_doneKey) ?? false) return;

    Future<void> attempt(List<ConnectivityResult> r) async {
      if (_downloading || r.contains(ConnectivityResult.none)) return;
      await _download(prefs);
    }

    await attempt(await Connectivity().checkConnectivity());
    if (!(prefs.getBool(_doneKey) ?? false)) {
      _connSub ??= Connectivity().onConnectivityChanged.listen(attempt);
    }
  }

  Future<void> _download(SharedPreferences prefs) async {
    _downloading = true;
    progress.value = 0;
    try {
      final region = RectangleRegion(bounds).toDownloadable(
        minZoom: minZoom,
        maxZoom: maxCachedZoom,
        options: TileLayer(
          urlTemplate: urlTemplate,
          userAgentPackageName: userAgent,
        ),
      );
      final stream = const FMTCStore(_storeName).download
          .startForeground(region: region, skipExistingTiles: true);
      await for (final p in stream) {
        progress.value = p.percentageProgress;
      }
      await prefs.setBool(_doneKey, true);
      await _connSub?.cancel();
      _connSub = null;
    } catch (e) {
      debugPrint(
        'Offline map download failed: $e',
      ); // retried on next connection
    } finally {
      progress.value = null;
      _downloading = false;
    }
  }
}
