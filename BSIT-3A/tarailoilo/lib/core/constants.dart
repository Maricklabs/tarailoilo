/// App-wide constants taken from PROJECT_PROMPT.md.
abstract final class AppConstants {
  static const appName = 'TaraIlo';

  /// Timeout for every AI call (chat, scan, event extraction).
  static const aiTimeout = Duration(seconds: 15);

  /// Timeout for ordinary Supabase reads.
  static const networkTimeout = Duration(seconds: 15);

  /// Allowed geofence radius range for landmarks, in meters.
  static const geofenceMinRadiusM = 50;
  static const geofenceMaxRadiusM = 100;

  /// Supported content languages (Contentful locales).
  static const supportedLanguages = {'en': 'English', 'fil': 'Filipino'};
}
