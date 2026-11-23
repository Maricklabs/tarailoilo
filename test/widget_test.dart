import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iloilo_tourist_app/app/app.dart';
import 'package:iloilo_tourist_app/app/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smoke test for the navigation skeleton: a returning guest who already
/// finished onboarding lands on Home and can switch tabs.
void main() {
  testWidgets('Splash routes a returning guest to Home tabs', (tester) async {
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

    // Wait for the splash check to finish.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Tara, Iloilo!'), findsOneWidget);

    await tester.tap(find.text('Dining'));
    await tester.pumpAndSettle();
    expect(find.text('S9'), findsOneWidget);
  });
}
