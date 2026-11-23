import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants.dart';

/// S1 Splash & Sync Check.
///
/// Shows the logo while the app checks the offline pack and (if online)
/// starts pulling content deltas. When done it calls
/// `SessionController.finishSplash()`, and the router's redirect sends the
/// user to Onboarding (first run), Login, or the bottom navigation.
///
/// TODO(sync owner): check the offline pack version and start
/// `SyncService.pullDeltas()` in the background here.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _runStartupChecks();
  }

  /// Placeholder for the real offline-pack / sync check.
  Future<void> _runStartupChecks() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    ref.read(sessionProvider.notifier).finishSplash();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.travel_explore, size: 72, color: scheme.onPrimary),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: scheme.onPrimary),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: scheme.onPrimary),
          ],
        ),
      ),
    );
  }
}
