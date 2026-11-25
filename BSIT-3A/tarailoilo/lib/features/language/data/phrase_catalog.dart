/// A phrase as consumed by the phrasebook and phrase detail screens.
class PhraseEntry {
  const PhraseEntry({
    required this.id,
    required this.category,
    required this.local,
    required this.english,
    required this.pronunciation,
    this.filipinoMeaning,
    this.audioUrl,
    this.isEmergency = false,
  });

  final String id;
  final String category;
  final String local;
  final String english;
  final String pronunciation;
  final String? filipinoMeaning;
  final String? audioUrl;
  final bool isEmergency;

  factory PhraseEntry.fromJson(Map<String, dynamic> json) {
    String requiredText(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException(
          'Phrase field "$key" must be a non-empty string.',
        );
      }
      return value;
    }

    final isEmergency = json['isEmergency'];
    if (isEmergency != null && isEmergency is! bool) {
      throw const FormatException(
        'Phrase field "isEmergency" must be a boolean.',
      );
    }

    final filipinoMeaning = json['filipinoMeaning'];
    final audioUrl = json['audioUrl'];
    if (filipinoMeaning != null && filipinoMeaning is! String) {
      throw const FormatException(
        'Phrase field "filipinoMeaning" must be text.',
      );
    }
    if (audioUrl != null && audioUrl is! String) {
      throw const FormatException('Phrase field "audioUrl" must be text.');
    }

    return PhraseEntry(
      id: requiredText('phraseId'),
      category: requiredText('category'),
      local: requiredText('localPhrase'),
      english: requiredText('englishMeaning'),
      pronunciation: requiredText('pronunciation'),
      filipinoMeaning: filipinoMeaning is String ? filipinoMeaning : null,
      audioUrl: audioUrl is String ? audioUrl : null,
      isEmergency: isEmergency is bool ? isEmergency : false,
    );
  }

  Map<String, Object?> toJson() => {
    'phraseId': id,
    'category': category,
    'localPhrase': local,
    'englishMeaning': english,
    'pronunciation': pronunciation,
    'filipinoMeaning': filipinoMeaning,
    'audioUrl': audioUrl,
    'isEmergency': isEmergency,
  };
}

PhraseEntry? findPhraseById(String id, Iterable<PhraseEntry> phrases) {
  for (final phrase in phrases) {
    if (phrase.id == id) return phrase;
  }
  return null;
}
