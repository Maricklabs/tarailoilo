import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../data/chat_content.dart';
import '../../../widgets/components.dart' show AccountButton;
import '../../../widgets/detail_parts.dart' show RoundBackButton;
import '../controllers/chat_controller.dart';
import '../controllers/chat_providers.dart';
import '../widgets/chat_widgets.dart';

/// The one Ask TATA page. Every TATA button in the app opens this same screen.
///
/// It is shown on top of whatever screen opened it (see Dashboard), so Back
/// returns there with its state and scroll position untouched. The conversation
/// lives in [controller], owned by the Dashboard, so it survives closing and reopening.
class ChatbotScreen extends ConsumerWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AskTataScreen(
        controller: ref.watch(chatControllerProvider),
        onBack: () => context.pop(),
        onAccount: () => context.push(AppRoutes.profile),
      );
}

class AskTataScreen extends StatefulWidget {
  const AskTataScreen({
    super.key,
    required this.controller,
    required this.onBack,
    required this.onAccount,
  });

  final ChatController controller;
  final VoidCallback onBack;
  final VoidCallback onAccount;

  @override
  State<AskTataScreen> createState() => _AskTataScreenState();
}

class _AskTataScreenState extends State<AskTataScreen> with WidgetsBindingObserver {
  final _scroll = ScrollController();
  final _focus = FocusNode();

  // Messages that existed when the screen opened appear instantly; only new ones animate.
  late final int _seenCount = widget.controller.messages.length;
  bool _keyboardOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_scrollToEnd);
    _scrollToEnd(animate: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_scrollToEnd);
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  // The keyboard opening or closing changes the visible height: hide the suggestions
  // while typing (to leave room for the conversation) and keep the latest message in view.
  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final open = View.of(context).viewInsets.bottom > 0;
    if (open != _keyboardOpen) {
      setState(() => _keyboardOpen = open);
      _scrollToEnd();
    }
  }

  void _scrollToEnd({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final end = _scroll.position.maxScrollExtent;
      if (animate) {
        _scroll.animateTo(end, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      } else {
        _scroll.jumpTo(end);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.controller;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ChatHeader(
            backButton: RoundBackButton(onTap: widget.onBack),
            accountButton: AccountButton(onTap: widget.onAccount),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: ListenableBuilder(
                listenable: chat,
                builder: (context, _) => ConversationView(
                  messages: chat.messages,
                  isTyping: chat.isTyping,
                  scroll: _scroll,
                  animateFromIndex: _seenCount,
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.ease,
            alignment: Alignment.topCenter,
            child: _keyboardOpen
                ? const SizedBox(width: double.infinity)
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: kChatMaxWidth),
                        child: ListenableBuilder(
                          listenable: chat,
                          builder: (context, _) => SuggestedQuestions(
                            questions: kSuggestedQuestions,
                            enabled: !chat.isTyping,
                            onSelected: (q) => chat.send(q.text),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          ListenableBuilder(
            listenable: chat,
            builder: (context, _) => ChatInput(
              focusNode: _focus,
              busy: chat.isTyping,
              onSend: chat.send,
            ),
          ),
        ],
      ),
    );
  }
}
