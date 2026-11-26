import 'dart:math' as math;
import '/data/chat_content.dart';
import '/models/chat_message.dart';

final _rng = math.Random();

/// Front-end only for now: returns a placeholder reply after a short delay.
///
/// This is the ONE function to replace when the AI backend exists. The screen
/// and [ChatController] only depend on this signature:
///   message -> reply text (throw on failure).
/// [history] already includes the new user message, ready to send as context.
Future<String> askTata(String message, {required List<ChatMessage> history}) async {
  await Future.delayed(Duration(milliseconds: 900 + _rng.nextInt(900)));
  // TODO: call the real AI API here with `history`.

  final topic = _topicFor(message);
  if (topic != null) return kPlaceholderReplies[topic]!;
  return kFallbackReplies[history.length % kFallbackReplies.length];
}

String? _topicFor(String message) {
  final q = message.trim().toLowerCase();

  // 1. exact match with a suggested question
  for (final s in kSuggestedQuestions) {
    if (s.text.toLowerCase() == q) return s.id;
  }
  // 2. keyword match for free-typed questions
  for (final e in kTopicKeywords.entries) {
    if (e.value.any(q.contains)) return e.key;
  }
  return null;
}
