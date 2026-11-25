import 'package:flutter/material.dart';

import '../../../widgets/feature_placeholder.dart';

/// A2 Content Manager.
///
/// CRUD phrases with audio upload. Read-only list of mirrored Contentful landmarks and dishes (last sync, verification, Open in Contentful, Re-sync now). Geofence editor.
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class AdminContentScreen extends StatelessWidget {
  const AdminContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Content Manager')),
      body: FeaturePlaceholder(
        code: 'A2',
        description:
            'CRUD phrases with audio upload. Read-only list of mirrored Contentful landmarks and dishes (last sync, verification, Open in Contentful, Re-sync now). Geofence editor.',
      ),
    );
  }
}
