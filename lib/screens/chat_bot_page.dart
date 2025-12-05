import 'package:flutter/material.dart';

class ChatBotPage extends StatelessWidget {
  final String lang;
  const ChatBotPage({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    // теперь можно использовать lang для перевода
    return Container(
      color: Colors.grey.shade200,
      child: Center(child: Text("ChatBot Page ($lang)")),
    );
  }
}
