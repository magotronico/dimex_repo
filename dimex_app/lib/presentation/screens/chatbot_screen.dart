import 'dart:convert';
import 'package:dimex_app/presentation/widgets/chat_model.dart';
import 'package:dimex_app/presentation/widgets/typingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  var textController = TextEditingController();
  var isBotThinking = false;
  var scrollController = ScrollController();
  int textFieldLines = 1; // Tracks current number of lines in the text field

  final List<ChatMessage> messages = [];
  WebSocketChannel? channel;

  @override
  void initState() {
    super.initState();
    initializeWebSocketConnection();

    textController.addListener(() {
      setState(() {
        int lineCount = '\n'.allMatches(textController.text).length + 1;
        textFieldLines = lineCount.clamp(1, 3); // Ensure the lines are between 1 and 3
      });
    });
  }


  Future<void> initializeWebSocketConnection() async {
    setState(() {
      channel = IOWebSocketChannel.connect(
        'wss://dimex-api.azurewebsites.net/ws/chat',
        headers: {"Authorization": "Bearer YOUR_VALID_TOKEN"},
      );
    });

    channel?.stream.listen((data) {
      // Parse the incoming data as JSON and extract the "answer" field
      String botResponse;
      try {
        final jsonResponse = jsonDecode(data); // Decode JSON
        botResponse = jsonResponse['answer'] ?? "No answer found"; // Extract "answer" value
      } catch (e) {
        botResponse = "Error: Could not parse response"; // Handle parsing errors
      }

      // print("Message received: $botResponse");
      setState(() {
        isBotThinking = false;
        if (messages.isNotEmpty &&
            messages.last.type == ChatMessageType.typing) {
          messages.removeLast();
        }

        messages.add(ChatMessage(text: botResponse, type: ChatMessageType.bot)); // Add only the extracted answer text
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  void dispose() {
    channel?.sink.close();
    textController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add(ChatMessage(text: text, type: ChatMessageType.user));
        isBotThinking = true;
        messages.add(ChatMessage(text: '', type: ChatMessageType.typing));
        textController.clear();
        textFieldLines = 1; // Reset the lines to 1 after sending
      });
      channel?.sink.add(jsonEncode([6, text]));
      // print("Message sent: $text");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat con Dimii'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final chat = messages[index];
                  return chatBubble(chatText: chat.text ?? '', type: chat.type);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatBubble({required String chatText, required ChatMessageType? type}) {
  if (type == ChatMessageType.typing) {
    return TypingIndicator();
  }
  return Row(
    mainAxisAlignment: type == ChatMessageType.bot
        ? MainAxisAlignment.start
        : MainAxisAlignment.end,
    children: [
      if (type == ChatMessageType.bot)
        CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Image(image: AssetImage('assets/chatBot.png')),
        ),
      if (type == ChatMessageType.bot) const SizedBox(width: 8),
      Flexible(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8, // Limit to 80% of screen width
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: type == ChatMessageType.bot
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Html(
              data: chatText,
              style: {
                "body": Style(
                  color: type == ChatMessageType.bot
                      ? Colors.black
                      : Theme.of(context).colorScheme.onPrimary,
                  fontSize: FontSize(14),
                  display: Display.inlineBlock, // Prevent Html from stretching
                  fontWeight: FontWeight.normal,
                ),
              },
            ),
          ),
        ),
      ),
    ],
  );
}

}
