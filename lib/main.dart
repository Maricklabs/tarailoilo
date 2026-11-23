import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/remote/supabase_service.dart';

/// Entry point of TaraIlo.
///
/// 1. Makes sure Flutter is ready before we touch plugins.
/// 2. Connects to Supabase (only if the URL and anon key were provided with
///    `--dart-define-from-file=.env`; the app still runs offline without them).
/// 3. Loads SharedPreferences once so every provider can read it synchronously.
/// 4. Starts the app inside a Riverpod [ProviderScope].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TaraIloApp(),
    ),
  );
}
