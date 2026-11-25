/// Build-time configuration supplied with `--dart-define-from-file`.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const contentfulSpaceId = String.fromEnvironment(
    'CONTENTFUL_SPACE_ID',
  );
  static const contentfulDeliveryToken = String.fromEnvironment(
    'CONTENTFUL_DELIVERY_TOKEN',
  );
  static const contentfulEnvironment = String.fromEnvironment(
    'CONTENTFUL_ENVIRONMENT',
    defaultValue: 'master',
  );
  static const contentfulPhraseContentType = String.fromEnvironment(
    'CONTENTFUL_PHRASE_CONTENT_TYPE',
    defaultValue: 'phrase',
  );

  /// `false` when Supabase URL and anon key were not supplied at build time.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasContentful =>
      contentfulSpaceId.isNotEmpty && contentfulDeliveryToken.isNotEmpty;
}
