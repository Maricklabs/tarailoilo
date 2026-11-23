import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S7 Saved & Downloads.
///
/// Favorited places, dishes, phrases and events, plus offline pack management (size, update, delete).
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved & Downloads')),
      body: FeaturePlaceholder(
        code: 'S7',
        description:
            'Favorited places, dishes, phrases and events, plus offline pack management (size, update, delete).',
        links: [
          PlaceholderLink('Sample landmark (S15)', AppRoutes.landmark('sample-landmark')),
          PlaceholderLink('Sample dish (S10)', AppRoutes.dish('sample-dish')),
          PlaceholderLink('Sample phrase (S19)', AppRoutes.phrase('sample-phrase')),
          PlaceholderLink('Sample event (S21)', AppRoutes.event('sample-event')),
        ],
      ),
    );
  }
}
