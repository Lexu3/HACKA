import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/favorites_service.dart';

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
  void initState() {
    super.initState();
    _loadFavoritesData();
    FavoritesService.instance.addListener(() {
      _loadFavoritesData();
    });
  }

  // Favorites data for suggestions
  List<String> favCodes = [];
  Map<String, String> favNames = {}; // code -> name
  List<MapEntry<String, String>> favDirections = []; // (uniCode, dirName)

  Future<void> _loadFavoritesData() async {
    final codes = FavoritesService.instance.favoritesList;
    final dirKeys = FavoritesService.instance.favoriteDirectionsList;
    final dirPairs = dirKeys.map((k) {
      final parts = k.split('|');
      final uni = parts.isNotEmpty ? parts.first : '';
      final dir = parts.length > 1 ? parts.sublist(1).join('|') : '';
      return MapEntry(uni, dir);
    }).toList();

    // Collect codes to fetch names for
    final needed = <String>{...codes};
    needed.addAll(dirPairs.map((e) => e.key));

    final Map<String, String> names = {};
    if (needed.isNotEmpty) {
      try {
        final docs = await Future.wait(needed.map((c) => FirebaseFirestore.instance.collection('universities').doc(c).get()));
        for (final d in docs) {
          if (d.exists) {
            final data = d.data();
            names[d.id] = (data != null && data['name'] is String) ? data['name'] as String : d.id;
          }
        }
      } catch (_) {
        // ignore fetch errors for suggestions
      }
    }

    if (!mounted) return;
    setState(() {
      favCodes = codes;
      favNames = names;
      favDirections = dirPairs;
    });
  }

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
        child: Column(
          children: [
            // Suggestion card when chat is empty
            if (messages.isEmpty) _buildSuggestionsCard(context),
            Expanded(
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
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Хотите сравнить вузы или направления?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ElevatedButton(
                    onPressed: favCodes.length >= 2 ? () => _compareUniversities() : null,
                    child: const Text('Сравнить избранные вузы'),
                  ),
                  ElevatedButton(
                    onPressed: favDirections.length >= 2 ? () => _compareDirections() : null,
                    child: const Text('Сравнить избранные направления'),
                  ),
                  // show chips for each favorite university
                  ...favCodes.map((c) {
                    final name = favNames[c] ?? c;
                    return ActionChip(label: Text(name), onPressed: () => _sendQuickCompare([c]));
                  }),
                  // chips for directions
                  ...favDirections.map((e) {
                    final uniName = favNames[e.key] ?? e.key;
                    final label = '$uniName — ${e.value}';
                    return ActionChip(label: Text(label), onPressed: () => _sendQuickCompareDirection(e));
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendQuickCompare(List<String> codes) {
    // Build a simple compare prompt for selected codes
    final names = codes.map((c) => favNames[c] ?? c).toList();
    final prompt = 'Сравни, пожалуйста, следующие университеты: ${names.join(', ')}. ' 
        'Кратко опиши сильные стороны, ориентировочную стоимость обучения, наличие общежития и грантов, и какие направления стоит рассмотреть.';
    final chatMessage = ChatMessage(user: currentUser, text: prompt, createdAt: DateTime.now());
    _inputController.clear();
    _sendMessage(chatMessage);
  }

  void _sendQuickCompareDirection(MapEntry<String, String> pair) {
    final uni = favNames[pair.key] ?? pair.key;
    final dir = pair.value;
    final prompt = 'Сравни направление "$dir" в университете $uni: какие сильные стороны, перспективы трудоустройства и каков ожидаемый проходной балл.';
    final chatMessage = ChatMessage(user: currentUser, text: prompt, createdAt: DateTime.now());
    _inputController.clear();
    _sendMessage(chatMessage);
  }

  void _compareUniversities() {
    if (favCodes.length < 2) return;
    final names = favCodes.map((c) => favNames[c] ?? c).toList();
    final prompt = 'Сравни, пожалуйста, следующие университеты: ${names.join(', ')}. ' 
        'Сравнение по стоимости обучения, условиям проживания, наличию грантов, и лучшим направлениям.';
    final chatMessage = ChatMessage(user: currentUser, text: prompt, createdAt: DateTime.now());
    _inputController.clear();
    _sendMessage(chatMessage);
  }

  void _compareDirections() {
    if (favDirections.length < 2) return;
    final samples = favDirections.take(4).map((e) => '${favNames[e.key] ?? e.key}: ${e.value}').toList();
    final prompt = 'Сравни, пожалуйста, следующие направления: ${samples.join('; ')}. ' 
        'Укажи различия в требованиях, перспективах и примерные проходные баллы.';
    final chatMessage = ChatMessage(user: currentUser, text: prompt, createdAt: DateTime.now());
    _inputController.clear();
    _sendMessage(chatMessage);
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