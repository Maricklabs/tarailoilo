import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S11 Restaurant.
///
/// Address, hours, contact, map pin, dishes served with dated allergen declarations, and directions.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  /// ID taken from the route path.
  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurant')),
      body: FeaturePlaceholder(
        code: 'S11',
        description:
            'Address, hours, contact, map pin, dishes served with dated allergen declarations, and directions.',
        links: [
          PlaceholderLink('Sample dish (S10)', AppRoutes.dish('sample-dish')),
          PlaceholderLink('Directions on map (S14)', AppRoutes.map, icon: Icons.directions),
        ],
      ),
    );
  }
}
