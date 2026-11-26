import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/env.dart';
import 'phrase_catalog.dart';

const _phrasebookCacheKey = 'phrasebook_cache_v1';

enum PhrasebookSource { contentful, savedOffline }

class PhrasebookUnavailableException implements Exception {
  const PhrasebookUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PhrasebookSnapshot {
  const PhrasebookSnapshot({
    required this.phrases,
    required this.source,
    this.notice,
  });

  final List<PhraseEntry> phrases;
  final PhrasebookSource source;
  final String? notice;

  String get sourceLabel => switch (source) {
    PhrasebookSource.contentful => 'Phrase pack synced from Contentful',
    PhrasebookSource.savedOffline => 'Saved phrase pack shown offline',
  };
}

class PhrasebookRepository {
  PhrasebookRepository(this._preferences, {http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final SharedPreferences _preferences;
  final http.Client _client;
  final bool _ownsClient;

  Future<PhrasebookSnapshot> load() async {
    final cached = await _readCache();
    if (!Env.hasContentful) {
      if (cached != null) {
        return _offlineSnapshot(
          cached,
          'Contentful is not configured; showing the saved offline copy.',
        );
      }
      throw const PhrasebookUnavailableException(
        'Contentful is not configured. Provide CONTENTFUL_SPACE_ID and '
        'CONTENTFUL_DELIVERY_TOKEN to load the phrasebook.',
      );
    }

    try {
      final phrases = await _fetchContentfulPhrases();

      var cacheSaved = false;
      try {
        cacheSaved = await _preferences.setString(
          _phrasebookCacheKey,
          jsonEncode(phrases.map((phrase) => phrase.toJson()).toList()),
        );
      } on Exception catch (error) {
        debugPrint('Could not save the phrasebook offline: $error');
      }
      return PhrasebookSnapshot(
        phrases: phrases,
        source: PhrasebookSource.contentful,
        notice: cacheSaved
            ? null
            : 'Phrase data loaded, but the offline copy was not saved.',
      );
    } on Exception catch (error) {
      debugPrint('Phrasebook CMS sync failed: $error');
      if (cached != null) {
        return _offlineSnapshot(
          cached,
          'Could not refresh phrases from Contentful; showing the saved offline copy.',
        );
      }
      throw const PhrasebookUnavailableException(
        'Could not load phrases from Contentful. Check the Delivery API '
        'configuration, network connection, and published Phrase entries.',
      );
    }
  }

  Future<List<PhraseEntry>> _fetchContentfulPhrases() async {
    final entries = <Map<String, dynamic>>[];
    final audioAssets = <String, String>{};
    var skip = 0;
    var total = 0;
    const limit = 1000;

    do {
      final uri = Uri.https(
        'cdn.contentful.com',
        '/spaces/${Env.contentfulSpaceId}/environments/'
            '${Env.contentfulEnvironment}/entries',
        {
          'content_type': Env.contentfulPhraseContentType,
          'include': '1',
          'limit': '$limit',
          'skip': '$skip',
        },
      );
      final response = await _client
          .get(
            uri,
            headers: {'Authorization': 'Bearer ${Env.contentfulDeliveryToken}'},
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw http.ClientException(
          'Contentful Delivery API returned HTTP ${response.statusCode}.',
          uri,
        );
      }

      final payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic> ||
          payload['items'] is! List ||
          payload['total'] is! int) {
        throw const FormatException(
          'Contentful returned an invalid entries response.',
        );
      }

      final pageItems = payload['items'] as List;
      for (final item in pageItems) {
        if (item is! Map) {
          throw const FormatException(
            'Contentful returned an invalid phrase entry.',
          );
        }
        entries.add(Map<String, dynamic>.from(item));
      }
      total = payload['total'] as int;
      _collectAudioAssets(payload['includes'], audioAssets);
      if (pageItems.isEmpty && skip < total) {
        throw const FormatException(
          'Contentful returned an incomplete entries page.',
        );
      }
      skip += pageItems.length;
    } while (skip < total);

    return entries
        .map((entry) {
          final fields = entry['fields'];
          if (fields is! Map) {
            throw const FormatException('Contentful phrase has no fields.');
          }
          return PhraseEntry.fromJson({
            'phraseId': fields['phraseId'],
            'category': fields['category'],
            'localPhrase': fields['localPhrase'],
            'englishMeaning': fields['englishMeaning'],
            'pronunciation': fields['pronunciation'],
            'filipinoMeaning': fields['filipinoMeaning'],
            'audioUrl': _audioUrl(fields['audioRecording'], audioAssets),
            'isEmergency': fields['isEmergency'] ?? false,
          });
        })
        .toList(growable: false);
  }

  void _collectAudioAssets(Object? includes, Map<String, String> audioAssets) {
    if (includes is! Map || includes['Asset'] is! List) return;
    for (final asset in includes['Asset'] as List) {
      if (asset is! Map || asset['sys'] is! Map || asset['fields'] is! Map) {
        continue;
      }
      final id = (asset['sys'] as Map)['id'];
      final file = (asset['fields'] as Map)['file'];
      if (id is! String || file is! Map || file['url'] is! String) continue;
      audioAssets[id] = file['url'] as String;
    }
  }

  String? _audioUrl(Object? audioLink, Map<String, String> audioAssets) {
    if (audioLink is! Map || audioLink['sys'] is! Map) return null;
    final assetId = (audioLink['sys'] as Map)['id'];
    if (assetId is! String) return null;
    final url = audioAssets[assetId];
    if (url == null) return null;
    return url.startsWith('//') ? 'https:$url' : url;
  }

  Future<List<PhraseEntry>?> _readCache() async {
    final encoded = _preferences.getString(_phrasebookCacheKey);
    if (encoded == null) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) {
        throw const FormatException('Cached phrase data must be a list.');
      }
      return decoded
          .map((item) {
            if (item is! Map) {
              throw const FormatException(
                'Cached phrase must be a JSON object.',
              );
            }
            return PhraseEntry.fromJson(Map<String, dynamic>.from(item));
          })
          .toList(growable: false);
    } on FormatException catch (error) {
      debugPrint('Discarding invalid phrasebook cache: $error');
      await _preferences.remove(_phrasebookCacheKey);
      return null;
    }
  }

  PhrasebookSnapshot _offlineSnapshot(List<PhraseEntry> cached, String notice) {
    return PhrasebookSnapshot(
      phrases: cached,
      source: PhrasebookSource.savedOffline,
      notice: notice,
    );
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
