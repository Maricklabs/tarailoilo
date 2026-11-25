import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S6 Ask Iloilo Guide.
///
/// Gemini + RAG chat via the gemini-chat Edge Function. Replies labeled AI with links to source entries, daily limit from chat_usage, offline keyword search over the bundled FAQ.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask Iloilo Guide')),
      body: FeaturePlaceholder(
        code: 'S6',
        description:
            'Gemini + RAG chat via the gemini-chat Edge Function. Replies labeled AI with links to source entries, daily limit from chat_usage, offline keyword search over the bundled FAQ.',
        links: [
          PlaceholderLink('Source: dish (S10)', AppRoutes.dish('sample-dish')),
          PlaceholderLink('Source: landmark (S15)', AppRoutes.landmark('sample-landmark')),
          PlaceholderLink('Source: phrase (S19)', AppRoutes.phrase('sample-phrase')),
        ],
      ),
    );
  }
}
