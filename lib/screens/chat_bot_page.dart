import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  final String lang;
  const ChatBotPage({super.key, required this.lang});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Бесплатный вариант: Hugging Face Inference API (есть free tier).
  // Получите ключ на https://huggingface.co/settings/tokens.
  // Рекомендуемый способ — передавать ключ через --dart-define при запуске:
  // flutter run --dart-define=HF_API_KEY=your_token_here
  static final String HF_API_KEY = const String.fromEnvironment('HF_API_KEY', defaultValue: '');
  static const String MODEL = 'gpt2'; // Можно заменить на другой публичный модельный endpoint

  Future<String> _queryHuggingFace(String prompt) async {
    final url = Uri.parse('https://api-inference.huggingface.co/models/$MODEL');
    final body = jsonEncode({
      'inputs': prompt,
      'parameters': {'max_new_tokens': 150}
    });

    final resp = await http.post(url, headers: {
      'Authorization': 'Bearer $HF_API_KEY',
      'Content-Type': 'application/json'
    }, body: body).timeout(const Duration(seconds: 30));

    if (resp.statusCode == 200) {
      try {
        final decoded = jsonDecode(resp.body);
        // Некоторые модели возвращают list with generated_text
        if (decoded is List && decoded.isNotEmpty && decoded[0]['generated_text'] != null) {
          return decoded[0]['generated_text'] as String;
        }
        // Some endpoints return a string or map
        if (decoded is Map && decoded['generated_text'] != null) {
          return decoded['generated_text'] as String;
        }
        // Fallback: return raw body
        return resp.body;
      } catch (e) {
        return 'Ошибка разбора ответа: ${e.toString()}';
      }
    } else {
      return 'Ошибка ${resp.statusCode}: ${resp.body}';
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    if (HF_API_KEY.isEmpty) {
      setState(() {
        _messages.add({'role': 'bot', 'text': 'Hugging Face API key not set. Запустите с --dart-define=HF_API_KEY=...'});
      });
      return;
    }

    final userMessage = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add({'role': 'user', 'text': userMessage});
      _isLoading = true;
    });

    try {
      final prompt = '''Ты помощник для абитуриентов, ищущих информацию об университетах.
Отвечай кратко и полезно на вопросы о:
- Университетах Казахстана
- Процессе поступления
- Программах обучения
- Стипендиях и грантах

Вопрос: $userMessage''';

      final answer = await _queryHuggingFace(prompt);

      setState(() {
        _messages.add({'role': 'bot', 'text': answer});
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': 'Ошибка: ${e.toString()}'});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чат-бот помощник'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Привет! Задайте вопрос об университетах',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      final isUser = message['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blueAccent : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['text']!,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Введите вопрос...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  backgroundColor: Colors.blueAccent,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
