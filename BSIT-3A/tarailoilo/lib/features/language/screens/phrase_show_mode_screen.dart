
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:iloilo_tourist_app/features/language/controllers/phrasebook_provider.dart';
import 'package:iloilo_tourist_app/features/language/data/phrase_catalog.dart';
import 'package:iloilo_tourist_app/features/language/data/phrasebook_repository.dart';
import 'package:iloilo_tourist_app/features/language/widgets/phrase_audio_player.dart';
import 'package:iloilo_tourist_app/widgets/state_views.dart';

/// S19 "Show to the other person" mode.
///
/// Full screen with large Hiligaynon text and local-speaker audio playback.
class PhraseShowModeScreen extends ConsumerWidget {
  const PhraseShowModeScreen({
    super.key,
    required this.phraseId,
  });

  final String phraseId;

  static const Color primary = Color(0xFFB04491);
  static const Color lightPink = Color(0xFFF7EDF5);
  static const Color borderPink = Color(0xFFEBD2E6);
  static const Color textColor = Color(0xFF765E70);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(phrasebookProvider).when(
      loading: () => const Scaffold(
        body: LoadingView(),
      ),
      error: (error, _) => Scaffold(
        body: ErrorView(
          message: 'Could not load the phrasebook.\n$error',
          onRetry: () => ref.invalidate(phrasebookProvider),
        ),
      ),
      data: (snapshot) => _buildShowMode(context, snapshot),
    );
  }

  Widget _buildShowMode(
    BuildContext context,
    PhrasebookSnapshot snapshot,
  ) {
    final phrase = findPhraseById(phraseId, snapshot.phrases);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: phrase == null
            ? const Center(
                child: Text('This phrase is not available.'),
              )
            : Column(
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
                            const Icon(
                              Icons.account_circle_outlined,
                              color: primary,
                              size: 35,
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

                  // PHRASE CONTENT
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // DISPLAY LABELS
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
                                    Icon(
                                      Icons.fullscreen,
                                      size: 13,
                                      color: primary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Large display',
                                      style: TextStyle(
                                        color: primary,
                                        fontSize: 9,
                                      ),
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
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // LARGE PHRASE CARD
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              minHeight: 220,
                            ),
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
                                  size: 24,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  phrase.local,
                                  style: const TextStyle(
                                    color: primary,
                                    fontSize: 31,
                                    fontWeight: FontWeight.bold,
                                    height: 1.22,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  phrase.english,
                                  style: const TextStyle(
                                    color: primary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // PRONUNCIATION AND AUDIO
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
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  phrase.pronunciation,
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // CONTENTFUL AUDIO PLAYER
                                PhraseAudioPlayer(
                                  key: ValueKey('show-audio-${phrase.id}',),
                                  audioUrl: phrase.audioUrl,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // EXIT BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                backgroundColor: lightPink,
                                foregroundColor: primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: const Text(
                                'Exit show mode',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
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
