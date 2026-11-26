import 'dart:async';

/// Front-end only for now. Every function below is a stub with a simulated delay.
/// Replace the bodies with real calls (Firebase Auth, REST API, etc.) later;
/// the screens only depend on these function signatures.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthUser {
  const AuthUser(this.email);
  final String email;
}

Future<void> _delay(int ms) => Future.delayed(Duration(milliseconds: ms));

Future<AuthUser> login({
  required String email,
  required String password,
  required bool remember,
}) async {
  await _delay(600);
  // TODO: real email/password login
  return AuthUser(email);
}

Future<AuthUser> signUp({required String email, required String password}) async {
  await _delay(600);
  // TODO: create account and send the 6-digit OTP to `email`
  return AuthUser(email);
}

Future<AuthUser> signInWithGoogle() async {
  await _delay(700);
  // TODO: real Google sign-in; return the chosen account's email
  return const AuthUser('google.user@example.com');
}

Future<bool> resendOtp(String email) async {
  await _delay(600);
  // TODO: trigger a new OTP email
  return true;
}

Future<bool> verifyOtp(String email, String code) async {
  await _delay(600);
  // TODO: validate against the backend. Stub accepts only 123456.
  if (code != '123456') {
    throw AuthException('That code is incorrect. Check it and try again.');
  }
  return true;
}

Future<bool> saveProfile(Map<String, String> profile) async {
  await _delay(600);
  // TODO: persist name, age, gender, nationality, contact number
  return true;
}
