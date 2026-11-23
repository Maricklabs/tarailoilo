/// Public configuration read at build time.
///
/// Values come from `.env` through
/// `flutter run --dart-define-from-file=.env` (see `.env.example`).
///
/// SECURITY: only the Supabase URL and the Supabase ANON key may live here.
/// Gemini, Contentful and Apify keys are Supabase secrets used by the Edge
/// Functions — never put them in the app or in git.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// `false` when the app was started without a `.env` file. The app still
  /// opens (offline features work) but cloud calls are skipped.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
