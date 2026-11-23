import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S15 Landmark.
///
/// Description, history, photos, hours, entry fee, favorite, save for offline, and related places.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class LandmarkDetailScreen extends StatelessWidget {
  const LandmarkDetailScreen({super.key, required this.landmarkId});

  /// ID taken from the route path.
  final String landmarkId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Landmark')),
      body: FeaturePlaceholder(
        code: 'S15',
        description:
            'Description, history, photos, hours, entry fee, favorite, save for offline, and related places.',
        links: [
          PlaceholderLink('Related places (S5)', '${AppRoutes.recommendations}?from=$landmarkId'),
        ],
      ),
    );
  }
}
