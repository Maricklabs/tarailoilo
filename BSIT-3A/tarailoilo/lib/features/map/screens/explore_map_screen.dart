import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/routes.dart';
import '../controllers/places_tracker.dart';
import '../../../data/iloilo_places.dart';
import '../../../data/offline_map_service.dart';
import '../widgets/explore_map_widgets.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  final _mapController = MapController();
  final _tracker = PlacesTracker.instance;
  final _offline = OfflineMapService.instance;

  late final Future<void> _ready;
  late final TileProvider _tiles;
  PlaceCategory? _filter; // null = all

  @override
  void initState() {
    super.initState();
    _ready = _offline.ensureInitialised().then(
      (_) => _tiles = _offline.tileProvider(),
    );
    _offline.downloadWhenOnline();
    _tracker.onPlacePassed = _showPassedBanner;
    _tracker.addListener(_onTrackerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTracking());
  }

  @override
  void dispose() {
    _tracker.removeListener(_onTrackerChanged);
    if (_tracker.onPlacePassed == _showPassedBanner)
      _tracker.onPlacePassed = null;
    _mapController.dispose();
    super.dispose();
  }

  void _onTrackerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _startTracking() async {
    final ok = await _tracker.start();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turn on location access to track your route.'),
        ),
      );
    }
  }

  void _showPassedBanner(Place place) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('You passed ${place.name}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MapHeader(
            onScan: () => context.push(AppRoutes.scan(mode: 'landmark')),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MapLegend(),
                const SizedBox(height: 8),
                PlaceFilterDropdown(
                  value: _filter,
                  onChanged: (v) => setState(() => _filter = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: FutureBuilder<void>(
                  future: _ready,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildMap();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final places = kIloiloPlaces
        .where((p) => _filter == null || p.category == _filter)
        .toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(10.7020, 122.5600),
            initialZoom: 13.5,
            minZoom: OfflineMapService.minZoom.toDouble(),
            maxZoom: 18,
            cameraConstraint: CameraConstraint.contain(
              bounds: OfflineMapService.bounds,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: OfflineMapService.urlTemplate,
              userAgentPackageName: OfflineMapService.userAgent,
              tileProvider: _tiles,
              maxNativeZoom:
                  OfflineMapService.maxCachedZoom, // overzoom cached tiles
            ),
            if (_tracker.path.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: List.of(_tracker.path),
                    strokeWidth: 5,
                    color: mapMagenta,
                    borderStrokeWidth: 1.5,
                    borderColor: Colors.white,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (final p in places)
                  placeMarker(p, () => showPlaceDetailsSheet(context, p)),
              ],
            ),
            if (_tracker.current != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _tracker.current!,
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
            const SimpleAttributionWidget(
              source: Text('© OpenStreetMap contributors'),
            ),
          ],
        ),
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: OfflineDownloadBanner(service: _offline),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: MapOverlayControls(
            tracking: _tracker.tracking,
            onRecenter: () {
              final c = _tracker.current;
              if (c != null) _mapController.move(c, 16);
            },
            onToggleRecording: () =>
                _tracker.tracking ? _tracker.stop() : _startTracking(),
          ),
        ),
      ],
    );
  }
}
