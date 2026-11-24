/// Phrase data used by the phrasebook and phrase detail screens.
///
/// Replace [samplePhraseData] with CMS-backed records when that integration
/// is available.
class PhraseEntry {
  const PhraseEntry({
    required this.id,
    required this.category,
    required this.local,
    required this.english,
    required this.pronunciation,
  });

  final String id;
  final String category;
  final String local;
  final String english;
  final String pronunciation;
}

const samplePhraseData = <PhraseEntry>[
  PhraseEntry(
    id: 'batchoy',
    category: 'FOOD ORDERING',
    local: 'Isa ka batchoy, palihog.',
    english: 'One batchoy, please.',
    pronunciation: 'ee-sa ka bat-choy, pa-lee-hog',
  ),
  PhraseEntry(
    id: 'how-much',
    category: 'BARGAINING',
    local: 'Tagpila ini?',
    english: 'How much is this?',
    pronunciation: 'tag-pee-la ee-nee',
  ),
  PhraseEntry(
    id: 'where-is-the-road',
    category: 'DIRECTIONS',
    local: 'Diin ang dalan?',
    english: 'Where is the road?',
    pronunciation: 'dee-in ang da-lan',
  ),
  PhraseEntry(
    id: 'allergy',
    category: 'ALLERGIES',
    local: 'May allergy ako.',
    english: 'I have an allergy.',
    pronunciation: 'may al-ler-gee a-ko',
  ),
  PhraseEntry(
    id: 'please-help',
    category: 'EMERGENCIES',
    local: 'Buligi ako!',
    english: 'Please help me!',
    pronunciation: 'bu-li-gee a-ko',
  ),
];

PhraseEntry? findPhraseById(String id) {
  for (final phrase in samplePhraseData) {
    if (phrase.id == id) return phrase;
  }
  return null;
}
