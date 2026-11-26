import '/data/groq_service.dart';
import '/models/chat_message.dart';

final _ai = GroqService();

Future<String> askTata(String message, {required List<ChatMessage> history}) =>
    _ai.ask(history);

Future<List<String>> suggestFollowUps(List<ChatMessage> history) =>
    _ai.suggest(history);
