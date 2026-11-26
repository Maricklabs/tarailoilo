enum ChatRole { user, tata }

/// One message in the Ask TATA conversation.
/// Kept deliberately small so it maps 1:1 onto a future AI API payload
/// (role + content), with an id and timestamp for the UI.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime sentAt;
}
