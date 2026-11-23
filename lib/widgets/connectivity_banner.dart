import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';

/// Global online/offline strip shown at the top of every screen.
///
/// It listens to [isOnlineProvider]. When the device is offline a small bar
/// tells the user that the app is now reading only local data.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key, required this.child});

  /// The page produced by the router.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = switch (ref.watch(isOnlineProvider)) {
      AsyncData(:final value) => value,
      _ => true, // Assume online while checking or if the plugin fails.
    };
    if (online) return child;

    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Material(
          color: scheme.errorContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 16, color: scheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Text(
                    'You are offline. Showing saved content.',
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ],
              ),
            ),
          ),
        ),
        // The banner already handled the status bar, so remove the top
        // padding for the page below it.
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
    );
  }
}
