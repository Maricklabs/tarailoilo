import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_controller.dart';

final chatControllerProvider = Provider<ChatController>((ref) {
  final c = ChatController();
  ref.onDispose(c.dispose);
  return c;
});