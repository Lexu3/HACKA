import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../theme.dart';
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
      return const AppScaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final t = texts[lang]!;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(t['header'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.greenDark)),
        actions: [
          TextButton(onPressed: toggleLang, child: Text(t['lang'], style: const TextStyle(color: Color.fromARGB(255, 46, 95, 51)))),
          IconButton(icon: const Icon(Icons.person_outline, color: Color.fromARGB(255, 24, 48, 33)), onPressed: openProfile),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: MainScreen(lang: lang),
          ),
        ],
      ),
    );
  }
}
