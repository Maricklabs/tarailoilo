import 'package:flutter/material.dart';

import '../../../widgets/feature_placeholder.dart';

/// S17 Route Detail.
///
/// Draws the recorded GPS points as a polyline and uploads the route once back online.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class RouteDetailScreen extends StatelessWidget {
  const RouteDetailScreen({super.key, required this.routeId});

  /// ID taken from the route path.
  final String routeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Detail')),
      body: FeaturePlaceholder(
        code: 'S17',
        description:
            'Draws the recorded GPS points as a polyline and uploads the route once back online.',
      ),
    );
  }
}
