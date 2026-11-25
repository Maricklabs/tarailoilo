import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../widgets/state_views.dart';
import '../controllers/phrasebook_provider.dart';
import '../data/phrase_catalog.dart';
import '../widgets/phrase_audio_button.dart';

/// S19 Phrase.
///
/// Hiligaynon text, pronunciation respelling, meaning, and real-speaker audio played from local files.
///
class PhraseDetailScreen extends ConsumerWidget {
  const PhraseDetailScreen({super.key, required this.phraseId});

  /// ID taken from the route path.
  final String phraseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(phrasebookProvider)
        .when(
          loading: () => const Scaffold(body: LoadingView()),
          error: (error, _) => Scaffold(
            body: ErrorView(
              message: 'Could not load the phrasebook.\n$error',
              onRetry: () => ref.invalidate(phrasebookProvider),
            ),
          ),
          data: (snapshot) {
            final phrase = findPhraseById(phraseId, snapshot.phrases);
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    phrase.english,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
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
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: PhraseAudioButton(
                              audioUrl: phrase.audioUrl,
                              compact: true,
                            ),
                            title: Text('Local-speaker recording'),
                            subtitle: Text(
                              phrase.audioUrl == null
                                  ? 'Recording pending.'
                                  : 'Recording available.',
                            ),
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
          },
        );
  }
}
