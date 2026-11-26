import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iloilo_tourist_app/app/app.dart';
import 'package:iloilo_tourist_app/app/providers.dart';
import 'package:iloilo_tourist_app/widgets/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smoke test for the navigation: a returning guest goes from the splash
/// screen straight into the bottom-navigation shell.
void main() {
  testWidgets('Splash routes a returning guest to the tabs', (tester) async {
    SharedPreferences.setMockInitialValues({
      PrefKeys.onboardingDone: true,
      PrefKeys.isGuest: true,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          isOnlineProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: const TaraIloApp(),
      ),
    );

    // Let the splash animation finish. pumpAndSettle is not used because
    // the new design has looping animations that never "settle".
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.byType(AppShell), findsOneWidget);
  });
}
