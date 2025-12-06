import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _HomePageState();
}

class _HomePageState extends State<ChatBotPage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  List<ChatMessage> pendingMessages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "Вы");
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: "Чат-бот",
      );
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Чат-бот",
        ),
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: false,
        onKey: (event) {
          if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.space) {
            // send only when input is focused and has content
            if (_inputFocus.hasFocus) {
              final text = _inputController.text;
              if (text.trim().isNotEmpty) {
                final chatMessage = ChatMessage(user: currentUser, text: text.trim(), createdAt: DateTime.now());
                _inputController.clear();
                _sendMessage(chatMessage);
              }
            }
          }
        },
        child: DashChat(
          currentUser: currentUser,
          onSend: _sendMessage,
          messages: messages,
          inputOptions: InputOptions(
            textController: _inputController,
            focusNode: _inputFocus,
            sendOnEnter: false,
          ),
          messageOptions: MessageOptions(
            // Provide a custom row builder that wraps the message body in
            // Expanded so long content doesn't overflow the Row.
            messageRowBuilder: (message, previousMessage, nextMessage, isAfterDateSeparator, isBeforeDateSeparator) {
              final isOwn = message.user.id == currentUser.id;
              final avatar = DefaultAvatar(user: message.user);
              final time = Text(
                '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              );

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isOwn) avatar,
                    if (!isOwn) const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isOwn ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(isOwn ? 12 : 16),
                                topRight: Radius.circular(isOwn ? 16 : 12),
                                bottomLeft: const Radius.circular(12),
                                bottomRight: const Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              _sanitizeForWrapping(message.text),
                              style: TextStyle(color: isOwn ? Colors.white : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft, child: time),
                        ],
                      ),
                    ),
                    if (isOwn) const SizedBox(width: 8),
                    if (isOwn) avatar,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      ChatMessage responseMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: "", // Изначально пустой текст
      );
      setState(() {
        messages = [responseMessage, ...messages]; // Добавляем пустое сообщение от Gemini
      });

      gemini.promptStream(
        parts: [Part.text(question)],
      ).listen(
        (response) {
          if (response == null) return;
          final content = response.output;
          if (content != null) {
            final safeChunk = _sanitizeForWrapping(content, maxRun: 24);
            setState(() {
              responseMessage.text += safeChunk;
              final index = messages.indexWhere((msg) =>
                  msg.user == geminiUser && msg.createdAt == responseMessage.createdAt);
              if (index != -1) {
                messages[index] = responseMessage;
              }
            });
          }
        },
        onDone: () {
          debugPrint("Стрим от Gemini завершен");
        },
        onError: (error) {
          debugPrint("Ошибка при получении стрима от Gemini: $error");
          final errText = error.toString();
          ChatMessage errorMessage = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: 'Произошла ошибка при получении ответа: $errText',
          );
          setState(() {
            messages = [errorMessage, ...messages];
          });
        },
      );
    } catch (e) {
      debugPrint("Ошибка при отправке запроса к Gemini: $e");
      ChatMessage errorMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: "Произошла ошибка.",
      );
      setState(() {
        messages = [errorMessage, ...messages];
      });
    }
  }

  // Insert zero-width spaces into very long unbroken strings so Text can wrap.
  String _sanitizeForWrapping(String input, {int maxRun = 12}) {
    // First, break long unbroken tokens (non-whitespace sequences).
    String result = input.replaceAllMapped(RegExp(r"(\S{${maxRun},})"), (m) {
      final s = m[0]!;
      final buffer = StringBuffer();
      for (var i = 0; i < s.length; i += maxRun) {
        final end = (i + maxRun < s.length) ? i + maxRun : s.length;
        buffer.write(s.substring(i, end));
        if (end < s.length) buffer.write('\u200B');
      }
      return buffer.toString();
    });

    // As a secondary measure, insert ZWSP after common delimiters to allow
    // natural breaking points (e.g., long URLs or JSON-like strings).
    result = result.replaceAllMapped(RegExp(r"([/\\_.-])"), (m) => '${m[1]}\u200B');

    return result;
  }
}