import 'package:flutter/material.dart';

import '../../../widgets/feature_placeholder.dart';

/// A5 Users & Limits.
///
/// View users and roles, adjust chat limits, clear login lockouts, disable users (admin-users Edge Function).
///
/// TODO(feature owner): replace [FeaturePlaceholder] with the real UI. Any
/// data loading must show LoadingView / EmptyView / ErrorView
/// (see lib/widgets/state_views.dart).
class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users & Limits')),
      body: FeaturePlaceholder(
        code: 'A5',
        description:
            'View users and roles, adjust chat limits, clear login lockouts, disable users (admin-users Edge Function).',
      ),
    );
  }
}
