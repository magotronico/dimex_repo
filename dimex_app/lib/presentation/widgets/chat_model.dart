enum ChatMessageType { user, bot, typing }

class ChatMessage {
  ChatMessage({required this.text, required this.type});

  String? text;
  ChatMessageType? type;
}
