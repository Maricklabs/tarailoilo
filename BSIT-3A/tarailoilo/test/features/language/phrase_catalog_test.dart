import 'package:flutter_test/flutter_test.dart';
import 'package:iloilo_tourist_app/core/env.dart';
import 'package:iloilo_tourist_app/features/language/data/phrasebook_repository.dart';
import 'package:iloilo_tourist_app/features/language/data/phrase_catalog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('maps Contentful phrase fields to the app phrase model', () {
    final phrase = PhraseEntry.fromJson({
      'phraseId': 'batchoy',
      'category': 'FOOD ORDERING',
      'localPhrase': 'Isa ka batchoy, palihog.',
      'englishMeaning': 'One batchoy, please.',
      'pronunciation': 'ee-sa ka bat-choy, pa-lee-hog',
      'filipinoMeaning': 'Isang batchoy, pakiusap.',
      'audioUrl': 'https://cdn.example.com/batchoy.mp3',
      'isEmergency': false,
    });

    expect(phrase.id, 'batchoy');
    expect(phrase.category, 'FOOD ORDERING');
    expect(phrase.local, 'Isa ka batchoy, palihog.');
    expect(phrase.english, 'One batchoy, please.');
    expect(phrase.pronunciation, 'ee-sa ka bat-choy, pa-lee-hog');
    expect(phrase.filipinoMeaning, 'Isang batchoy, pakiusap.');
    expect(phrase.audioUrl, 'https://cdn.example.com/batchoy.mp3');
    expect(phrase.isEmergency, isFalse);
  });

  test('rejects CMS records missing required phrase text', () {
    expect(
      () => PhraseEntry.fromJson({
        'phraseId': 'batchoy',
        'category': 'FOOD ORDERING',
      }),
      throwsFormatException,
    );
  });

  test(
    'reports missing Contentful setup instead of returning sample phrases',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      await expectLater(
        PhrasebookRepository(preferences).load(),
        throwsA(
          isA<PhrasebookUnavailableException>().having(
            (error) => error.message,
            'message',
            contains('CONTENTFUL_SPACE_ID'),
          ),
        ),
      );
    },
    skip: Env.hasContentful
        ? 'Contentful config is supplied for this run.'
        : false,
  );
}
