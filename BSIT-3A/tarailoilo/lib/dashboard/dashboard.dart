import 'package:flutter/material.dart';
import '../widgets/anim.dart';
import 'components.dart';
import 'content.dart';
import 'pages.dart';

enum DashPage { home, detail, account, events }

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DashPage _page = DashPage.home;
  List<String> _stack = []; // detail history (ids)
  String _nav = 'home';
  final _homeScroll = ScrollController();
  final _askKey = GlobalKey();

  @override
  void dispose() {
    _homeScroll.dispose();
    super.dispose();
  }

  void _openItem(ContentItem it) => setState(() {
        _stack = [..._stack, it.id];
        _page = DashPage.detail;
      });

  void _back() {
    if (_stack.length > 1) {
      setState(() => _stack = _stack.sublist(0, _stack.length - 1));
    } else {
      setState(() {
        _stack = [];
        _page = DashPage.home;
      });
    }
  }

  void _goHome() => setState(() {
        _stack = [];
        _page = DashPage.home;
      });

  void _openAccount() => setState(() => _page = DashPage.account);

  void _openEvents() => setState(() {
        _nav = 'events';
        _page = DashPage.events;
      });

  void _onNav(String id) {
    setState(() => _nav = id);
    if (id == 'home') _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final current = _stack.isNotEmpty ? getItem(_stack.last) : null;
    final home = _page == DashPage.home;

    return PopScope(
      canPop: home,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_page == DashPage.detail) {
          _back();
        } else {
          _goHome();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Home stays mounted (hidden) so its state and scroll position survive a detail visit.
            Positioned.fill(
              child: Offstage(
                offstage: !home,
                child: Home(
                  scroll: _homeScroll,
                  askKey: _askKey,
                  onOpen: _openItem,
                  onAccount: _openAccount,
                  onSeeAll: _openEvents,
                ),
              ),
            ),
            if (_page == DashPage.detail && current != null)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.white,
                  child: FadeIn(
                    key: ValueKey('detail-${current.id}-${_stack.length}'),
                    child: Detail(
                      key: ValueKey(current.id),
                      item: current,
                      onBack: _back,
                      onOpen: _openItem,
                    ),
                  ),
                ),
              ),
            if (_page == DashPage.account)
              Positioned.fill(
                child: ColoredBox(color: Colors.white, child: Blank(name: 'account-settings', onBack: _goHome)),
              ),
            if (_page == DashPage.events)
              Positioned.fill(
                child: ColoredBox(color: Colors.white, child: Blank(name: 'events', onBack: _goHome)),
              ),
            FloatingTata(targetKey: _askKey, scroll: _homeScroll, enabled: home),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: BottomNav(active: _nav, onSelect: _onNav),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
