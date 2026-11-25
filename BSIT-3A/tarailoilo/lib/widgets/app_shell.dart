import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/routes.dart';

/// The frame around the 5 main tabs: the current tab's page, the bottom
/// [NavigationBar] (Home, Dining, Map, Language, Events — exact order from
/// the spec) and the floating "Ask Guide" button that opens the chatbot (S6).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  /// Provided by go_router's StatefulShellRoute. It shows the active tab and
  /// remembers each tab's own navigation stack.
  final StatefulNavigationShell navigationShell;

  /// Switches tab. Tapping the tab you are already on pops it back to its
  /// first page (the usual mobile behaviour).
  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'ask-guide-fab',
        onPressed: () => context.push(AppRoutes.chat),
        icon: const Icon(Icons.support_agent),
        label: const Text('Ask Guide'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Dining',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.translate_outlined),
            selectedIcon: Icon(Icons.translate),
            label: 'Language',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}
