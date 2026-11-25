/// Every route path in the app, in one place.
///
/// Always navigate with these constants/helpers (for example
/// `context.push(AppRoutes.dish(id))`) instead of typing raw strings, so a
/// path can be renamed safely. Screen codes (S1..S21, A1..A5) match
/// PROJECT_PROMPT.md section 5.
abstract final class AppRoutes {
  // ---- Entry flow (outside the bottom navigation) ----
  static const splash = '/splash'; // S1
  static const onboarding = '/onboarding'; // S2
  static const login = '/login'; // S3
  static const forgotPassword = '/login/forgot-password'; // S3 (sub-flow)

  // ---- Tab 1: Home ----
  static const home = '/home'; // S4
  static const recommendations = '/home/recommendations'; // S5
  static const saved = '/home/saved'; // S7
  static const profile = '/home/profile'; // S8

  // ---- Tab 2: Dining ----
  static const dining = '/dining'; // S9
  static String dish(String id) => '/dining/dish/$id'; // S10
  static String restaurant(String id) => '/dining/restaurant/$id'; // S11

  // ---- Tab 3: Map ----
  static const map = '/map'; // S14
  static String landmark(String id) => '/map/landmark/$id'; // S15
  static const placesPassed = '/map/places-passed'; // S16
  static String route(String id) => '/map/route/$id'; // S17

  // ---- Tab 4: Language ----
  static const language = '/language'; // S18
  static String phrase(String id) => '/language/phrase/$id'; // S19
  static String phraseShow(String id) => '/language/phrase/$id/show'; // S19

  // ---- Tab 5: Events ----
  static const events = '/events'; // S20
  static String event(String id) => '/events/$id'; // S21

  // ---- Full-screen pages opened from any tab ----
  static const chat = '/chat'; // S6 (floating "Ask Guide" button)
  static String scan({String mode = 'dish'}) => '/scan?mode=$mode'; // S12
  static const scanResult = '/scan/result'; // S13

  // ---- Admin (role-guarded) ----
  static const admin = '/admin'; // A1
  static const adminContent = '/admin/content'; // A2
  static const adminEvents = '/admin/events'; // A3
  static const adminRestaurants = '/admin/restaurants'; // A4
  static const adminUsers = '/admin/users'; // A5
}
