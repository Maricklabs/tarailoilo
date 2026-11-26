// All Ask TATA text lives here, separate from the UI, so suggestions and
// placeholder replies can be edited (or later loaded from a backend) without
// touching any widget.

import 'package:iloilo_tourist_app/models/chat_message.dart';

const String kChatHeading = 'Ask TATA';
const String kChatSubtitle = "TARA ILO's Very own Chatbot";
const String kChatInputHint = 'Type Here.....';
const String kSuggestionsHeading = 'What Else can TATA help with?';
const String kChatEmptyTitle = "Hi, I'm TATA!";
const String kChatEmptyBody = 'Ask me anything about Iloilo: landmarks, food, events and culture.';
const String kChatErrorReply = "Sorry, I couldn't answer that right now. Please try again.";

/// A tappable suggested question. Replace this list to change the suggestions.
class SuggestedQuestion {
  const SuggestedQuestion(this.id, this.text);
  final String id;
  final String text;
}

const List<SuggestedQuestion> kSuggestedQuestions = [
  SuggestedQuestion('find-phrase', 'Find a phrase'),
  SuggestedQuestion('popular-events', 'What are the popular events in Iloilo?'),
  SuggestedQuestion('popular-foods', 'What are the popular foods in Iloilo?'),
];

/// Placeholder answers by topic id (suggestion ids plus 'camera').
/// Frontend only: the real answers will come from the AI backend.
const Map<String, String> kPlaceholderReplies = {
  'camera':
      'Open our camera feature, point your camera towards any food or landmark you want to know more about!',
  'find-phrase':
      "Sure! Tell me what you'd like to say, like \"thank you\" or \"how much is this?\", and I'll look for the Hiligaynon phrase. You can also open the Phrasebook from the Home shortcuts.",
  'popular-events':
      "Iloilo is famous for its festivals, like Dinagyang, the Paraw Regatta and the Jaro Fiesta. Check Ongoing Events on the Home page to see what's happening now.",
  'popular-foods':
      'You have to try La Paz Batchoy, Pancit Molo, Kadyos Baboy Langka (KBL) and Biscocho. Open Local Food on the Home page to learn where each one comes from.',
};

/// Words that route a free-typed question to one of the topics above.
const Map<String, List<String>> kTopicKeywords = {
  'camera': ['camera', 'lens', 'scan', 'photo'],
  'find-phrase': ['phrase', 'translate', 'hiligaynon', 'ilonggo', 'how do i say'],
  'popular-events': ['event', 'festival', 'dinagyang', 'paraw', 'fiesta'],
  'popular-foods': ['food', 'eat', 'batchoy', 'dish', 'delicacy', 'restaurant'],
};

/// Used when nothing matches.
const List<String> kFallbackReplies = [
  "That's a great question! I'm still learning, so my answers are limited for now. Try asking about landmarks, food or events in Iloilo.",
  "I don't have details on that yet. Ask me about Iloilo's landmarks, local food, events or phrases and I'll do my best!",
  'Thanks for asking! Full answers are coming soon. For now, explore the Landmarks and Local Food on the Home page.',
];

/// The conversation shown when the chat is first opened.
/// A function (not a const) because messages carry a timestamp.
List<ChatMessage> buildInitialConversation() {
  final now = DateTime.now();
  return [
    ChatMessage(
      id: 'seed-1',
      role: ChatRole.user,
      text: 'How do you use the camera feature?',
      sentAt: now,
    ),
    ChatMessage(
      id: 'seed-2',
      role: ChatRole.tata,
      text: kPlaceholderReplies['camera']!,
      sentAt: now,
    ),
  ];
}
