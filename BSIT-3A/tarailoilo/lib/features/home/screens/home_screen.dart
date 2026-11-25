import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S4 Home (Tab 1).
///
/// Final version: nearby landmarks (GPS), this month's events, closure
/// alerts, seasonal top-picks carousel, and quick actions (Scan, Phrasebook,
/// Ask Guide). The avatar in the app bar opens Profile (S8).
///
/// TODO(home owner): replace [FeaturePlaceholder] with the real sections.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tara, Iloilo!'),
        actions: [
          IconButton(
            tooltip: 'Saved',
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => context.push(AppRoutes.saved),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.push(AppRoutes.profile),
              child: const CircleAvatar(child: Icon(Icons.person)),
            ),
          ),
        ],
      ),
      body: FeaturePlaceholder(
        code: 'S4',
        description:
            'Nearby landmarks, this month\'s events, closure alerts, seasonal '
            'top picks, and quick actions.',
        links: [
          const PlaceholderLink('Trip recommendations (S5)', AppRoutes.recommendations),
          PlaceholderLink('Quick action: Scan (S12)', AppRoutes.scan(mode: 'landmark'),
              icon: Icons.camera_alt),
          const PlaceholderLink('Quick action: Phrasebook (S18)', AppRoutes.language,
              icon: Icons.translate),
          const PlaceholderLink('Quick action: Ask Guide (S6)', AppRoutes.chat,
              icon: Icons.support_agent),
          PlaceholderLink('Nearby landmark (S15)', AppRoutes.landmark('sample-landmark')),
          PlaceholderLink('This month\'s event (S21)', AppRoutes.event('sample-event')),
        ],
      ),
    );
  }
}
