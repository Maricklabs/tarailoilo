import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S16 Places Passed & Routes.
///
/// Offline timeline of places passed and recorded routes (date, distance, duration).
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class PlacesPassedScreen extends StatelessWidget {
  const PlacesPassedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Places Passed & Routes')),
      body: FeaturePlaceholder(
        code: 'S16',
        description:
            'Offline timeline of places passed and recorded routes (date, distance, duration).',
        links: [
          PlaceholderLink('Sample landmark (S15)', AppRoutes.landmark('sample-landmark')),
          PlaceholderLink('Sample route (S17)', AppRoutes.route('sample-route')),
        ],
      ),
    );
  }
}
