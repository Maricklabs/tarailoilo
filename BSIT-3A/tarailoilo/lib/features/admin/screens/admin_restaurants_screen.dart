import 'package:flutter/material.dart';

import '../../../widgets/feature_placeholder.dart';

/// A4 Restaurants & Allergens.
///
/// Restaurant directory, dishes served, and dated allergen declarations with their source.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class AdminRestaurantsScreen extends StatelessWidget {
  const AdminRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants & Allergens')),
      body: FeaturePlaceholder(
        code: 'A4',
        description:
            'Restaurant directory, dishes served, and dated allergen declarations with their source.',
      ),
    );
  }
}
