import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/routes.dart';
import '../data/content.dart';
import 'components.dart' show FloatingTata;
import 'pages.dart' show Detail;

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final item = getItem(id);
    if (item == null) {
      return const Scaffold(body: Center(child: Text('Not found')));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Detail(
              item: item,
              onBack: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
              onOpen: (it) => context.push(AppRoutes.forItem(it)),
            ),
          ),
          FloatingTata(enabled: true, onTap: () => context.push(AppRoutes.chat)),
        ],
      ),
    );
  }
}