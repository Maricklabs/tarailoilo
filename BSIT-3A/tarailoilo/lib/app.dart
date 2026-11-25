import 'package:flutter/material.dart';
import 'dashboard/dashboard.dart';
import 'screens/auth_screens.dart';
import 'widgets/anim.dart';
import 'screens/terms_screen.dart';

enum AppScreen { loading, welcome, login, signin, otp, info, guest, dashboard }

class TaraApp extends StatefulWidget {
  const TaraApp({super.key});

  @override
  State<TaraApp> createState() => _TaraAppState();
}

class _TaraAppState extends State<TaraApp> {
  AppScreen _screen = AppScreen.loading;
  String _email = '';
  bool _showTerms = false;

  void _go(AppScreen s) => setState(() => _screen = s);

  // The Terms screen opens on top of the current screen, so whatever the user typed stays put.
  void _openTerms() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _showTerms = true);
  }

  void _closeTerms() => setState(() => _showTerms = false);

  // back never replays the loader
  void _toWelcome() => _go(AppScreen.welcome);

  Widget _view() {
    switch (_screen) {
      case AppScreen.loading:
        return LoadingScreen(onDone: _toWelcome);
      case AppScreen.welcome:
        return WelcomeScreen(
          onLogin: () => _go(AppScreen.login),
          onGuest: () => _go(AppScreen.guest),
          onSignIn: () => _go(AppScreen.signin),
        );
      case AppScreen.login:
        return LoginScreen(
          onBack: _toWelcome,
          onOpenTerms: _openTerms,
          onDone: () => _go(AppScreen.dashboard),
        );
      case AppScreen.guest:
        return GuestAvatarScreen(
          onBack: _toWelcome,
          onOpenTerms: _openTerms,
          onComplete: () => _go(AppScreen.dashboard),
        );
      case AppScreen.signin:
        return SignInScreen(
          onBack: _toWelcome,
          onOpenTerms: _openTerms,
          onNext: (e) => setState(() {
            _email = e;
            _screen = AppScreen.otp;
          }),
        );
      case AppScreen.otp:
        return OtpScreen(email: _email, onVerified: () => _go(AppScreen.info));
      case AppScreen.info:
        return InfoScreen(
          onBack: () => _go(AppScreen.signin),
          onOpenTerms: _openTerms,
          onComplete: () => _go(AppScreen.dashboard),
        );
      case AppScreen.dashboard:
        return const Dashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: KeyedSubtree(
              key: ValueKey(_screen),
              child: FadeIn(child: _view()),
            ),
          ),
          if (_showTerms)
            Positioned.fill(
              child: FadeIn(child: TermsScreen(onClose: _closeTerms)),
            ),
        ],
      ),
    );
  }
}
