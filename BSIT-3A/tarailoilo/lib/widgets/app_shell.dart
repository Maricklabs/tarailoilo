import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'components.dart' show BottomNav;

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static const _ids = ['home', 'dining', 'map', 'language', 'events'];

  void _onSelect(String id) {
    final i = _ids.indexOf(id);
    navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: BottomNav(
                  active: _ids[navigationShell.currentIndex],
                  onSelect: _onSelect,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}