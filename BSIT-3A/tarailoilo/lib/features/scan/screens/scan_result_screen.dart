import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S13 Scan Result.
///
/// Top guesses with confidence, labeled AI. The user must confirm or pick the correct entry first. Falls back to manual search in S9.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: FeaturePlaceholder(
        code: 'S13',
        description:
            'Top guesses with confidence, labeled AI. The user must confirm or pick the correct entry first. Falls back to manual search in S9.',
        links: [
          PlaceholderLink('Confirm dish (S10)', AppRoutes.dish('sample-dish')),
          PlaceholderLink('Confirm landmark (S15)', AppRoutes.landmark('sample-landmark')),
          PlaceholderLink('Search manually (S9)', AppRoutes.dining, icon: Icons.search),
        ],
      ),
    );
  }
}
