import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/remote/supabase_service.dart';

/// App-wide Riverpod providers that more than one feature needs.
///
/// Feature-specific providers belong in `features/<feature>/controllers/`.

/// SharedPreferences instance. It is loaded in `main()` and injected with
/// `overrideWithValue`, so reading it here is always synchronous.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main() with the real prefs'),
);

/// `true` while the device has any network connection.
///
/// Used by the global offline banner and by features that must switch to
/// their offline fallback (chatbot, scan, reviews).
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool hasNetwork(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  yield hasNetwork(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(hasNetwork);
});

/// Keys used in SharedPreferences, kept in one place to avoid typos.
abstract final class PrefKeys {
  static const onboardingDone = 'onboarding_done';
  static const isGuest = 'is_guest';
  static const language = 'language';
}

/// Everything the router needs to know about who is using the app.
class AppSession {
  const AppSession({
    required this.splashDone,
    required this.onboardingDone,
    required this.isSignedIn,
    required this.isGuest,
    required this.isAdmin,
  });

  /// S1 finished its sync check and may leave the splash screen.
  final bool splashDone;

  /// The first-run onboarding (S2) has been completed on this device.
  final bool onboardingDone;

  /// A Supabase user is logged in.
  final bool isSignedIn;

  /// The user tapped "Continue as guest" on S3.
  final bool isGuest;

  /// The logged-in user has role = 'admin' in `profiles`.
  final bool isAdmin;

  /// Can the user see the bottom navigation (signed in OR guest)?
  bool get canEnterApp => isSignedIn || isGuest;

  AppSession copyWith({
    bool? splashDone,
    bool? onboardingDone,
    bool? isSignedIn,
    bool? isGuest,
    bool? isAdmin,
  }) {
    return AppSession(
      splashDone: splashDone ?? this.splashDone,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      isGuest: isGuest ?? this.isGuest,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

/// Holds and updates the [AppSession]. The router listens to it and
/// re-runs its redirect whenever the session changes.
///
/// TODO(auth owner): replace [signInStub] with the real Supabase email/password
/// login that goes through the `auth-guard` Edge Function, and load
/// `isAdmin` from the `profiles.role` column.
class SessionController extends Notifier<AppSession> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSession build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSession(
      splashDone: false,
      onboardingDone: prefs.getBool(PrefKeys.onboardingDone) ?? false,
      isSignedIn: SupabaseService.currentUser != null,
      isGuest: prefs.getBool(PrefKeys.isGuest) ?? false,
      isAdmin: false,
    );
  }

  /// Called by S1 Splash once the offline-pack / sync check is done.
  void finishSplash() => state = state.copyWith(splashDone: true);

  /// Called by S2 Onboarding when the user finishes the first-run flow.
  Future<void> completeOnboarding() async {
    await _prefs.setBool(PrefKeys.onboardingDone, true);
    state = state.copyWith(onboardingDone: true);
  }

  /// "Continue as guest" on S3. Offline features still work for guests.
  Future<void> continueAsGuest() async {
    await _prefs.setBool(PrefKeys.isGuest, true);
    state = state.copyWith(isGuest: true);
  }

  /// Placeholder login so the navigation can be tested before auth exists.
  void signInStub() => state = state.copyWith(isSignedIn: true, isGuest: false);

  /// Logs out (Supabase + guest flag) and sends the user back to S3.
  Future<void> signOut() async {
    await SupabaseService.signOut();
    await _prefs.setBool(PrefKeys.isGuest, false);
    state = state.copyWith(isSignedIn: false, isGuest: false, isAdmin: false);
  }

  /// DEBUG ONLY: lets developers open the admin screens before roles exist.
  void setDebugAdmin(bool value) => state = state.copyWith(isAdmin: value);
}

final sessionProvider = NotifierProvider<SessionController, AppSession>(
  SessionController.new,
);
