import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S3 Login / Register.
///
/// Final version: email + password form with validation and inline errors,
/// 5 attempts per IP then a lockout timer (enforced by the `auth-guard` Edge
/// Function), register, forgot password, and "Continue as guest".
///
/// TODO(auth owner): build the real form and replace `signInStub()`.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.read(sessionProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: FeaturePlaceholder(
        code: 'S3',
        description:
            'Email/password login and register with validation, auth-guard '
            'lockout, forgot password, and guest mode.',
        extra: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: session.signInStub,
              child: const Text('Sign in (stub)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: session.continueAsGuest,
              child: const Text('Continue as guest'),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.forgotPassword),
              child: const Text('Forgot password?'),
            ),
          ],
        ),
      ),
    );
  }
}
