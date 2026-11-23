import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S5 Trip Recommendations (core feature).
///
/// Seasonal top picks for the current month, rule-based "Because you visited
/// X" places (tags + distance + season), interest tag filters, and reviews
/// when online.
///
/// TODO(recommendations owner): replace [FeaturePlaceholder] with the real UI.
class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key, this.becauseYouVisitedId});

  /// Landmark ID passed as `?from=` when opened from S15 "related places".
  final String? becauseYouVisitedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Recommendations')),
      body: FeaturePlaceholder(
        code: 'S5',
        description:
            'Seasonal top picks, "Because you visited '
            '${becauseYouVisitedId ?? 'X'}" related places, tag filters, '
            'and online reviews.',
        links: [
          PlaceholderLink('Recommended landmark (S15)', AppRoutes.landmark('sample-landmark')),
        ],
      ),
    );
  }
}
