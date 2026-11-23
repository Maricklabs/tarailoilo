import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../widgets/feature_placeholder.dart';

/// A1 Admin Dashboard (role-guarded).
///
/// Final version: counts of pending events, content items and users, plus
/// alerts for closures that are ending and out-of-date allergen declarations.
///
/// Non-admins never reach this page: the router redirect blocks `/admin`
/// and Supabase RLS blocks the data.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: const FeaturePlaceholder(
        code: 'A1',
        description:
            'Pending events, content items and user counts; ending-closure and '
            'stale-allergen alerts.',
        links: [
          PlaceholderLink('Content Manager (A2)', AppRoutes.adminContent, icon: Icons.library_books),
          PlaceholderLink('Events & Closures (A3)', AppRoutes.adminEvents, icon: Icons.event_note),
          PlaceholderLink('Restaurants & Allergens (A4)', AppRoutes.adminRestaurants, icon: Icons.storefront),
          PlaceholderLink('Users & Limits (A5)', AppRoutes.adminUsers, icon: Icons.people),
        ],
      ),
    );
  }
}
