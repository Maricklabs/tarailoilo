import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../features/language/controllers/phrasebook_provider.dart';
import '../features/language/data/phrase_catalog.dart';
import '../features/language/data/phrasebook_repository.dart';
import '../features/language/widgets/phrase_audio_button.dart';
import '../widgets/state_views.dart';

class PhraseDetailScreen extends ConsumerWidget {
  const PhraseDetailScreen({super.key, required this.phraseId});

  final String phraseId;

  static const Color primary = Color(0xFFB04491);
  static const Color lightPink = Color(0xFFF7EDF5);
  static const Color borderPink = Color(0xFFEBD2E6);
  static const Color textColor = Color(0xFF765E70);

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
          data: (snapshot) => _buildPhrasePage(context, snapshot),
        );
  }

  Widget _buildPhrasePage(BuildContext context, PhrasebookSnapshot snapshot) {
    final phrase = findPhraseById(phraseId, snapshot.phrases);
    if (phrase == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Phrasebook')),
        body: const Center(child: Text('This phrase is not available.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              color: lightPink,
              padding: const EdgeInsets.fromLTRB(15, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'TARA ILO',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push(AppRoutes.profile),
                        icon: const Icon(Icons.account_circle_outlined),
                        color: primary,
                        iconSize: 35,
                        tooltip: 'Profile',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Phrasebook',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
                  ),
                ],
              ),
            ),

            // MAIN CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LARGE DISPLAY AND OFFLINE LABELS
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: lightPink,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.fullscreen, size: 13, color: primary),
                              SizedBox(width: 4),
                              Text(
                                'Large display',
                                style: TextStyle(color: primary, fontSize: 9),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: lightPink,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Offline text',
                            style: TextStyle(color: primary, fontSize: 9),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // LARGE PHRASE CARD
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 220),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightPink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: primary,
                            size: 21,
                          ),

                          const SizedBox(height: 20),

                          Text(
                            phrase.local,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            phrase.english,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 9),

                    // PRONUNCIATION CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: borderPink),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pronunciation help',
                            style: TextStyle(
                              color: primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            phrase.pronunciation,
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Real local-speaker audio',
                                      style: TextStyle(
                                        color: primary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      phrase.audioUrl == null
                                          ? 'Recording pending - not yet playable'
                                          : 'Recording available',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PhraseAudioButton(
                                audioUrl: phrase.audioUrl,
                                compact: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    FilledButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.phraseShow(phrase.id)),
                      icon: const Icon(Icons.fullscreen),
                      label: const Text('Show phrase'),
                      style: FilledButton.styleFrom(backgroundColor: primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
