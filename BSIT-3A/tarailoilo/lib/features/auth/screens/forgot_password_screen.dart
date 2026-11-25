import 'package:flutter/material.dart';

import '../../../widgets/feature_placeholder.dart';

/// S3 Forgot Password.
///
/// Email field that sends a Supabase password-reset link, with validation and inline errors.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: FeaturePlaceholder(
        code: 'S3',
        description:
            'Email field that sends a Supabase password-reset link, with validation and inline errors.',
      ),
    );
  }
}
