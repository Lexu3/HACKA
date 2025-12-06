import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// (inline chat removed) Floating chat panel is used instead.
import 'main_screen.dart';
import 'profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String lang = "ru";
  Map<String, dynamic> texts = {};

  @override
  void initState() {
    super.initState();
    loadTranslations();
  }

  Future<void> loadTranslations() async {
    final data = await rootBundle.loadString('assets/translations.json');
    setState(() {
      texts = jsonDecode(data);
    });
  }

  void toggleLang() {
    setState(() {
      lang = lang == "ru" ? "kz" : "ru";
    });
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (texts.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final t = texts[lang]!;

    return Scaffold(
      body: Column(
        children: [
          // верхняя навигационная панель
          Container(
            height: 60,
            width: double.infinity,
            color: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t["header"],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: toggleLang,
                      child: Text(
                        t["lang"],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon:
                          const Icon(Icons.person_outline, color: Colors.white),
                      onPressed: openProfile,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // основной контент
          Expanded(
            child: Row(
              children: [
                // MainScreen occupies the full area now; floating chat button provides chat access.
                Expanded(
                  child: MainScreen(lang: lang),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
