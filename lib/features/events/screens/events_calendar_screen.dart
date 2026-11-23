import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S20 Events.
///
/// Month view and list of current and upcoming Iloilo events with category filters. AI-found events get an AI-found, admin-verified badge. Cached offline.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class EventsCalendarScreen extends StatelessWidget {
  const EventsCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: FeaturePlaceholder(
        code: 'S20',
        description:
            'Month view and list of current and upcoming Iloilo events with category filters. AI-found events get an AI-found, admin-verified badge. Cached offline.',
        links: [
          PlaceholderLink('Sample event (S21)', AppRoutes.event('sample-event')),
        ],
      ),
    );
  }
}
