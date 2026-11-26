
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:iloilo_tourist_app/app/routes.dart';
import 'package:iloilo_tourist_app/features/language/controllers/phrasebook_provider.dart';
import 'package:iloilo_tourist_app/features/language/data/phrase_catalog.dart';
import 'package:iloilo_tourist_app/features/language/widgets/phrase_audio_player.dart';
import 'package:iloilo_tourist_app/widgets/state_views.dart';

class PhrasebookScreen extends ConsumerStatefulWidget {
  const PhrasebookScreen({super.key});

  @override
  ConsumerState<PhrasebookScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<PhrasebookScreen> {
  final Color primary = const Color(0xFFB04491);
  final Color lightPink = const Color(0xFFF7EDF5);
  final Color borderPink = const Color(0xFFEBD2E6);
  final Color textColor = const Color(0xFF765E70);

  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';

  final List<String> categories = [
    'Ordering',
    'Allergies',
    'Directions',
    'Bargaining',
    'Emergencies',
    'Greetings',
    'Casual',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phrasebook = ref.watch(phrasebookProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              color: lightPink,
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 42),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: primary,
                        tooltip: 'Back',
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'TARA ILO',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push(AppRoutes.profile),
                        icon: const Icon(Icons.account_circle_outlined),
                        color: primary,
                        iconSize: 38,
                        tooltip: 'Profile',
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
                  Text(
                    'Phrasebook',
                    style: TextStyle(
                      color: primary,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // CONTENT
            Expanded(
              child: phrasebook.when(
                loading: () => const LoadingView(),
                error: (error, _) => ErrorView(
                  message: 'Could not load the phrasebook.\n$error',
                  onRetry: () => ref.invalidate(phrasebookProvider),
                ),
                data: (snapshot) {
                  final search = searchController.text.toLowerCase();

                  final hasAudio = snapshot.phrases.any(
                    (phrase) =>
                        phrase.audioUrl != null &&
                        phrase.audioUrl!.trim().isNotEmpty,
                  );

                  final filteredPhrases =
                      snapshot.phrases.where((phrase) {
                        final matchesCategory =
                            selectedCategory == 'All' ||
                            phrase.category.toUpperCase() ==
                                selectedCategory.toUpperCase();

                        final matchesSearch =
                            phrase.local.toLowerCase().contains(search) ||
                            phrase.english.toLowerCase().contains(search) ||
                            (phrase.filipinoMeaning?.toLowerCase().contains(
                                  search,
                                ) ??
                                false);

                        return matchesCategory && matchesSearch;
                      }).toList()
                        ..sort((a, b) {
                          if (a.isEmergency == b.isEmergency) return 0;
                          return a.isEmergency ? -1 : 1;
                        });

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(phrasebookProvider);
                      await ref.read(phrasebookProvider.future);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(25, 19, 25, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SEARCH BAR
                          Container(
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: borderPink),
                            ),
                            child: TextField(
                              controller: searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    'Search in Hiligaynon, English, or Filipino',
                                hintStyle: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: primary,
                                  size: 25,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),

                          const SizedBox(height: 17),

                          // CATEGORY FILTERS
                          Wrap(
                            spacing: 8,
                            runSpacing: 9,
                            children: [
                              categoryChip('All'),
                              ...categories.map(categoryChip),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // OFFLINE STATUS
                          Row(
                            children: [
                              Icon(Icons.download, color: primary, size: 23),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  [
                                    snapshot.sourceLabel,
                                    if (snapshot.notice != null)
                                      snapshot.notice!,
                                  ].join(' • '),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 17),

                          // PHRASE CARDS
                          if (filteredPhrases.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No phrases match your search.',
                                ),
                              ),
                            )
                          else
                            ...filteredPhrases.map(
                              (phrase) => phraseCard(phrase),
                            ),

                          const SizedBox(height: 2),

                          // INFORMATION CARD
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: lightPink,
                              border: Border.all(color: borderPink),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Made by people, not generated voices',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  hasAudio
                                      ? 'Phrase content is managed in Contentful. Local-speaker recordings are available for some phrases.'
                                      : 'Phrase content is managed in Contentful. Local-speaker recordings are pending.',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Recordings are streamed from Contentful when available.',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryChip(String category) {
    final isSelected = selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primary : lightPink,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget phraseCard(PhraseEntry phrase) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 17),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderPink),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            phrase.category,
            style: TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            phrase.local,
            style: TextStyle(
              color: primary,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            phrase.english,
            style: TextStyle(color: textColor, fontSize: 16),
          ),

          const SizedBox(height: 8),

          Text(
            phrase.pronunciation,
            style: TextStyle(color: textColor, fontSize: 14),
          ),

          const SizedBox(height: 12),

          // AUDIO PLAYER FROM CONTENTFUL
          PhraseAudioPlayer(
            key: ValueKey('phrase-audio-${phrase.id}'),
            audioUrl: phrase.audioUrl,
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(
                AppRoutes.phraseShow(phrase.id),
              ),
              child: Text(
                'Show phrase',
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
