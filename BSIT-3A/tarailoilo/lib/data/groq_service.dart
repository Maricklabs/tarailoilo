import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iloilo_tourist_app/models/chat_message.dart';

import 'tata_persona.dart';

/// Talks to the Groq API (OpenAI-compatible). Only [chat_service.dart] should use this.
class GroqService {
  // Check console.groq.com/docs/models if this stops working.
  // Faster/cheaper alternative: 'llama-3.1-8b-instant'.
  static const _model = 'openai/gpt-oss-120b';
  static final _url = Uri.parse(
    'https://api.groq.com/openai/v1/chat/completions',
  );

  /// Only the most recent messages are sent, to keep requests small and fast.
  static const _maxHistory = 20;

  static const _apiKey = String.fromEnvironment('GROQ_API_KEY');

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };

  /// system prompt + recent history, in OpenAI chat format.
  List<Map<String, String>> _messages(List<ChatMessage> history) {
    final recent = history.length > _maxHistory
        ? history.sublist(history.length - _maxHistory)
        : history;
    return [
      {'role': 'system', 'content': tataSystemPrompt},
      for (final m in recent)
        {
          'role': m.role == ChatRole.user ? 'user' : 'assistant',
          'content': m.text,
        },
    ];
  }

  String? _extractText(String responseBody) {
    final data = jsonDecode(responseBody);
    final text = data['choices']?[0]?['message']?['content'];
    if (text is! String || text.trim().isEmpty) return null;
    return text.trim();
  }

  /// Returns TATA's reply to the conversation. Throws on failure.
  Future<String> ask(List<ChatMessage> history) async {
    if (_apiKey.isEmpty) throw Exception('Missing GROQ_API_KEY in .env');

    final body = {
      'model': _model,
      'messages': _messages(history),
      'temperature': 0.8,
      'max_tokens': 1024,
      'reasoning_effort': 'low',
    };

    late http.Response res;
    for (var attempt = 0; attempt < 3; attempt++) {
      res = await http
          .post(_url, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
      // Retry only when Groq is busy or rate limiting.
      if (res.statusCode != 503 && res.statusCode != 429) break;
      await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
    }

    if (res.statusCode != 200) {
      throw Exception('Groq error ${res.statusCode}: ${res.body}');
    }

    final text = _extractText(res.body);
    if (text == null) throw Exception('Empty response');
    return text;
  }

  /// Up to 3 short follow-up questions. Returns [] on any failure.
  Future<List<String>> suggest(List<ChatMessage> history) async {
    if (_apiKey.isEmpty) return [];

    final body = {
      'model': _model,
      'messages': [
        ..._messages(history),
        {
          'role': 'user',
          'content':
              'Suggest 3 short follow-up questions (max 8 words each) that '
              'the visitor might ask next about Iloilo or the app. '
              'Write them from the visitor\'s point of view. '
              'Reply with JSON only, in this exact shape: '
              '{"questions": ["...", "...", "..."]}',
        },
      ],
      'temperature': 0.9,
      'max_tokens': 200,
      // Groq's JSON mode needs an object (not a bare array) and the word "JSON" in the prompt.
      'response_format': {'type': 'json_object'},
    };

    final res = await http
        .post(_url, headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) return [];

    final raw = _extractText(res.body);
    if (raw == null) return [];

    final data = jsonDecode(raw);
    final list = data is Map ? data['questions'] : null;
    if (list is! List) return [];
    return list
        .map((e) => e.toString().trim())
        .where((s) => s.isNotEmpty)
        .take(3)
        .toList();
  }
}
