import 'package:flutter/material.dart';

import '../../../widgets/feature_placeholder.dart';
import '../../../widgets/item_detail_page.dart';

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
    return ItemDetailPage(id: eventId);
  }
}
