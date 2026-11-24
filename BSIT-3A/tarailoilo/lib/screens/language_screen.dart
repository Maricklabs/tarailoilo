import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';
import '../features/language/data/phrase_catalog.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final Color primary = const Color(0xFFB04491);
  final Color lightPink = const Color(0xFFF7EDF5);
  final Color borderPink = const Color(0xFFEBD2E6);
  final Color textColor = const Color(0xFF765E70);

  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';
  final List<String> categories = [
    'Food ordering',
    'Allergies',
    'Directions',
    'Bargaining',
    'Emergencies',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = searchController.text.toLowerCase();

    final filteredPhrases = samplePhraseData.where((phrase) {
      final matchesCategory =
          selectedCategory == 'All' ||
          phrase.category == selectedCategory.toUpperCase();

      final matchesSearch =
          phrase.local.toLowerCase().contains(search) ||
          phrase.english.toLowerCase().contains(search);

      return matchesCategory && matchesSearch;
    }).toList();

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
              child: SingleChildScrollView(
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
                          hintText: 'Search phrases or English meaning',
                          hintStyle: TextStyle(color: textColor, fontSize: 14),
                          prefixIcon: Icon(
                            Icons.search,
                            color: primary,
                            size: 25,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 17),

                    // CATEGORY FILTERS
                    Wrap(
                      spacing: 8,
                      runSpacing: 9,
                      children: [...categories.map(categoryChip)],
                    ),

                    const SizedBox(height: 20),

                    // OFFLINE STATUS
                    Row(
                      children: [
                        Icon(Icons.download, color: primary, size: 23),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Text pack saved offline • audio pack pending',
                            style: TextStyle(color: textColor, fontSize: 13),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 17),

                    // PHRASE CARDS
                    ...filteredPhrases.map((phrase) => phraseCard(phrase)),

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
                            'Manually authored phrase & pronunciation drafts, awaiting native-speaker review. Real local-speaker recordings: pending.',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Download recordings when available',
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

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(Icons.play_circle_outline, color: primary, size: 23),
              const SizedBox(width: 7),
              Text(
                'Local speaker',
                style: TextStyle(color: textColor, fontSize: 12),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push(AppRoutes.phraseShow(phrase.id)),
                child: Text(
                  'Show phrase',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
