import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../widgets/feature_placeholder.dart';

/// S2 Onboarding & Offline Pack (first run only).
///
/// Final version: language choice (English/Filipino), permission
/// explanations (location, camera, notifications), and the Iloilo offline
/// pack download with progress bar, pause and retry.
///
/// TODO(onboarding owner): build the real steps. Keep calling
/// `completeOnboarding()` at the end so the router moves on to S3.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Iloilo')),
      body: FeaturePlaceholder(
        code: 'S2',
        description:
            'Language choice, permission explanations, and the offline pack '
            'download (map tiles, landmarks, dishes, phrases, audio) with '
            'progress, pause and retry.',
        extra: FilledButton(
          onPressed: () =>
              ref.read(sessionProvider.notifier).completeOnboarding(),
          child: const Text('Get started'),
        ),
      ),
    );
  }
}
