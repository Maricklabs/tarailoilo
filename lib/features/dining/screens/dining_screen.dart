import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S9 Dining.
///
/// Dishes and Restaurants sub-tabs with offline FTS search and filters (La Paz batchoy, pancit molo, KBL, Pinaupong Manok). Scan opens S12 in dish mode.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class DiningScreen extends StatelessWidget {
  const DiningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dining')),
      body: FeaturePlaceholder(
        code: 'S9',
        description:
            'Dishes and Restaurants sub-tabs with offline FTS search and filters (La Paz batchoy, pancit molo, KBL, Pinaupong Manok). Scan opens S12 in dish mode.',
        links: [
          PlaceholderLink('Scan a dish (S12)', AppRoutes.scan(mode: 'dish'), icon: Icons.camera_alt),
          PlaceholderLink('Sample dish (S10)', AppRoutes.dish('sample-dish')),
          PlaceholderLink('Sample restaurant (S11)', AppRoutes.restaurant('sample-restaurant')),
        ],
      ),
    );
  }
}
