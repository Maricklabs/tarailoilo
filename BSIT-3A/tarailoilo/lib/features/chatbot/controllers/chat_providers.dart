import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iloilo_tourist_app/models/chat_message.dart';

import 'chat_controller.dart';

final chatControllerProvider = Provider<ChatController>((ref) {
  final c = ChatController(
    initial: [
      ChatMessage(
        id: 'welcome',
        role: ChatRole.tata,
        text: 'Kamusta! I\'m Tata, your Iloilo travel buddy. Ask me about food, places, or festivals!',
        sentAt: DateTime.now(),
      ),
    ],
  );
  ref.onDispose(c.dispose);
  return c;
});
