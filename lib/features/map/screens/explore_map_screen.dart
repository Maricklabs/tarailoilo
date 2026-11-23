import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S14 Explore Map (Tab 3, core feature).
///
/// Final version: offline OSM map (flutter_map + MBTiles/PMTiles) with
/// landmark and restaurant pins, filters, the closure layer from S21,
/// foreground geofencing (50–100 m or polygons) that notifies and logs
/// "places passed", route recording start/stop, a landmark Scan button, and
/// OSM attribution.
///
/// TODO(map owner): replace [FeaturePlaceholder] with the map.
class ExploreMapScreen extends StatelessWidget {
  const ExploreMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Map')),
      body: FeaturePlaceholder(
        code: 'S14',
        description:
            'Offline Iloilo map with pins, filters, closures, geofence alerts, '
            'route recording, and landmark scan.',
        links: [
          PlaceholderLink('Geofence alert → landmark (S15)', AppRoutes.landmark('sample-landmark')),
          const PlaceholderLink('Places passed & routes (S16)', AppRoutes.placesPassed,
              icon: Icons.timeline),
          PlaceholderLink('Scan landmark (S12)', AppRoutes.scan(mode: 'landmark'),
              icon: Icons.camera_alt),
        ],
      ),
    );
  }
}
