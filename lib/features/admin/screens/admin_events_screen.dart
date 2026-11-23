import 'package:flutter/material.dart';

import '../../../widgets/feature_placeholder.dart';

/// A3 Events & Closures.
///
/// Review queue for AI-scraped events (approve, edit, reject), add events manually, draw closures with time windows and send alerts.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class AdminEventsScreen extends StatelessWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events & Closures')),
      body: FeaturePlaceholder(
        code: 'A3',
        description:
            'Review queue for AI-scraped events (approve, edit, reject), add events manually, draw closures with time windows and send alerts.',
      ),
    );
  }
}
