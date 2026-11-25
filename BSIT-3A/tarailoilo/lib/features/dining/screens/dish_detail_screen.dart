import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S10 Dish Detail.
///
/// Meaning, origin and history, ingredients. Allergens only as Declared by [restaurant] as of [date], never safe to eat. Restaurants serving the dish on a map.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class DishDetailScreen extends StatelessWidget {
  const DishDetailScreen({super.key, required this.dishId});

  /// ID taken from the route path.
  final String dishId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dish Detail')),
      body: FeaturePlaceholder(
        code: 'S10',
        description:
            'Meaning, origin and history, ingredients. Allergens only as Declared by [restaurant] as of [date], never safe to eat. Restaurants serving the dish on a map.',
        links: [
          PlaceholderLink('Sample restaurant (S11)', AppRoutes.restaurant('sample-restaurant')),
        ],
      ),
    );
  }
}
