import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// S21 Event Detail.
///
/// Date, venue, organizer, source link. Closures on the map with alternative routes, jeepney/terminal changes and parking. Remind me and area alerts.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.eventId});

  /// ID taken from the route path.
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Detail')),
      body: FeaturePlaceholder(
        code: 'S21',
        description:
            'Date, venue, organizer, source link. Closures on the map with alternative routes, jeepney/terminal changes and parking. Remind me and area alerts.',
        links: [
          PlaceholderLink('See closures on map (S14)', AppRoutes.map, icon: Icons.map),
        ],
      ),
    );
  }
}
