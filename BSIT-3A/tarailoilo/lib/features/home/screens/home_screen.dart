import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';
import '../../../widgets/components.dart' show FloatingTata;
import '../../../widgets/pages.dart' show Home;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();
  final _askKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void openChat() => context.push(AppRoutes.chat);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Home(
              scroll: _scroll,
              askKey: _askKey,
              onOpen: (it) => context.push(AppRoutes.forItem(it)),
              onAccount: () => context.push(AppRoutes.profile),
              onSeeAll: () => context.go(AppRoutes.events),
              onAsk: openChat,
            ),
          ),
          FloatingTata(targetKey: _askKey, scroll: _scroll, enabled: true, onTap: openChat),
        ],
      ),
    );
  }
}