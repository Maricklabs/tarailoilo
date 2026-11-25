import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env.dart';

/// Thin wrapper around the Supabase client.
///
/// All remote services (auth, sync, Edge Function clients) should get the
/// client from here, so the app keeps working when Supabase is not
/// configured (for example a teammate running without a `.env` file).
abstract final class SupabaseService {
  static bool _ready = false;

  /// `true` after [initialize] connected successfully.
  static bool get isReady => _ready;

  /// Connects to Supabase if the URL and anon key were provided.
  static Future<void> initialize() async {
    if (!Env.hasSupabase) return;
    // The anon (public) key is passed as the "publishable" key in
    // supabase_flutter 2.18+.
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
    _ready = true;
  }

  /// The Supabase client. Check [isReady] before using it.
  static SupabaseClient get client => Supabase.instance.client;

  /// The logged-in user, or `null` (also `null` when Supabase is off).
  static User? get currentUser => _ready ? client.auth.currentUser : null;

  /// Signs out of Supabase if it is configured.
  static Future<void> signOut() async {
    if (_ready) await client.auth.signOut();
  }
}
