import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../data/phrasebook_repository.dart';

final phrasebookProvider = FutureProvider<PhrasebookSnapshot>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  final repository = PhrasebookRepository(preferences);
  ref.onDispose(repository.dispose);
  return repository.load();
});