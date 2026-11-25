import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S18 Phrasebook.
///
/// Categories (ordering food, allergies, directions, bargaining, emergencies). Search in English, Filipino and Hiligaynon, emergency phrases pinned on top. Works 100% offline.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class PhrasebookScreen extends StatelessWidget {
  const PhrasebookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phrasebook')),
      body: FeaturePlaceholder(
        code: 'S18',
        description:
            'Categories (ordering food, allergies, directions, bargaining, emergencies). Search in English, Filipino and Hiligaynon, emergency phrases pinned on top. Works 100% offline.',
        links: [
          PlaceholderLink('Sample phrase (S19)', AppRoutes.phrase('sample-phrase')),
        ],
      ),
    );
  }
}
