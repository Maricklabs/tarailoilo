import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../data/phrase_catalog.dart';

/// S19 Phrase.
///
/// Hiligaynon text, pronunciation respelling, meaning, and real-speaker audio played from local files.
///
class PhraseDetailScreen extends StatelessWidget {
  const PhraseDetailScreen({super.key, required this.phraseId});

  /// ID taken from the route path.
  final String phraseId;

  @override
  Widget build(BuildContext context) {
    final phrase = findPhraseById(phraseId);

    return Scaffold(
      appBar: AppBar(title: const Text('Phrase')),
      body: phrase == null
          ? const Center(child: Text('This phrase is not available.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    phrase.category,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phrase.local,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            phrase.english,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pronunciation',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(phrase.pronunciation),
                  const SizedBox(height: 24),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.volume_up_outlined),
                    title: Text('Local-speaker recording'),
                    subtitle: Text('Sample audio is not available yet.'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.phraseShow(phrase.id)),
                    icon: const Icon(Icons.fullscreen),
                    label: const Text('Show phrase'),
                  ),
                ],
              ),
            ),
    );
  }
}
