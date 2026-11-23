import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';

/// S8 Profile & Settings.
///
/// Final version: edit profile, language, notification toggles, privacy
/// notice (RA 10173), delete account, and logout. Admins also see an
/// "Admin Panel" link to A1.
///
/// TODO(profile owner): add the real settings. The Admin Panel link and the
/// logout button are already wired to the router.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final controller = ref.read(sessionProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(session.isGuest ? 'Guest' : 'Signed-in user'),
            subtitle: const Text('S8 — placeholder'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('English / Filipino'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications'),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy notice (RA 10173)'),
          ),
          if (session.isAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin Panel'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.admin),
            ),
          // DEBUG ONLY — remove once roles come from Supabase `profiles`.
          if (kDebugMode)
            SwitchListTile(
              secondary: const Icon(Icons.bug_report_outlined),
              title: const Text('Dev: act as admin'),
              value: session.isAdmin,
              onChanged: controller.setDebugAdmin,
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(session.isGuest ? 'Leave guest mode' : 'Log out'),
            onTap: controller.signOut,
          ),
        ],
      ),
    );
  }
}
