import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S19 Phrase.
///
/// Hiligaynon text, pronunciation respelling, meaning, and real-speaker audio played from local files.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class PhraseDetailScreen extends StatelessWidget {
  const PhraseDetailScreen({super.key, required this.phraseId});

  /// ID taken from the route path.
  final String phraseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phrase')),
      body: FeaturePlaceholder(
        code: 'S19',
        description:
            'Hiligaynon text, pronunciation respelling, meaning, and real-speaker audio played from local files.',
        links: [
          PlaceholderLink('Show to the other person', AppRoutes.phraseShow(phraseId), icon: Icons.fullscreen),
        ],
      ),
    );
  }
}
