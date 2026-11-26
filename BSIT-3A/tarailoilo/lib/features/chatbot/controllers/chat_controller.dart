import 'package:flutter/foundation.dart';
import '/data/chat_content.dart';
import '/models/chat_message.dart';
import 'chat_service.dart';

/// Holds the Ask TATA conversation.
///
/// Owned by the Dashboard (not by the chat screen), so closing and reopening
/// the chat from any entry point shows the same conversation.
class ChatController extends ChangeNotifier {
  ChatController({List<ChatMessage>? initial})
      : _messages = List.of(initial ?? buildInitialConversation());

  final List<ChatMessage> _messages;
  bool _typing = false;
  bool _disposed = false;
  int _seq = 0;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// True while TATA is preparing a reply (drives the typing indicator).
  bool get isTyping => _typing;

  String _id() => '${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// Adds the user's message, then TATA's reply. Empty messages are ignored,
  /// and so is a send while TATA is still answering the previous one.
  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _typing) return;

    _messages.add(ChatMessage(id: _id(), role: ChatRole.user, text: text, sentAt: DateTime.now()));
    _typing = true;
    _notify();

    String reply;
    try {
      reply = await askTata(text, history: List.unmodifiable(_messages));
    } catch (_) {
      reply = kChatErrorReply;
    }
    if (_disposed) return;

    _messages.add(ChatMessage(id: _id(), role: ChatRole.tata, text: reply, sentAt: DateTime.now()));
    _typing = false;
    _notify();
  }

  /// Clears the conversation (shows the empty state).
  void clear() {
    _messages.clear();
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
