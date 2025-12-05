import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _HomePageState();
}

class _HomePageState extends State<ChatBotPage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "Вы");
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: "Чат-бот",
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Чат-бот",
        ),
      ),
      body: DashChat(
        currentUser: currentUser,
        onSend: _sendMessage,
        messages: messages,
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
          final content = response?.output;
          if (content != null) {
            setState(() {
              responseMessage.text += content; // <---- Вот это изменение
              final index = messages.indexWhere((msg) =>
                  msg.user == geminiUser &&
                  msg.createdAt == responseMessage.createdAt);
              if (index != -1) {
                messages[index] = responseMessage;
              }
            });
          }
        },
        onDone: () {
          print("Стрим от Gemini завершен");
        },
        onError: (error) {
          print("Ошибка при получении стрима от Gemini: $error");
          ChatMessage errorMessage = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: "Произошла ошибка при получении ответа.",
          );
          setState(() {
            messages = [errorMessage, ...messages];
          });
        },
      );
    } catch (e) {
      print("Ошибка при отправке запроса к Gemini: $e");
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
}