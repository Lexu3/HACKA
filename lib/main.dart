import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'firebase_options.dart';

import 'screens/home_page.dart';
import 'unis/example.dart' show uploadUniversities, clearAndUploadUniversities;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Gemini.init(apiKey: 'AIzaSyDUrMWkhieZmyG1eSoU8VO4liMZQhtn1x0');

  // Optional: run uploader automatically when starting the app with
  // --dart-define=UPLOAD_ACTION=add  (or 'clear')
  const uploadAction = String.fromEnvironment('UPLOAD_ACTION', defaultValue: '');
  if (uploadAction == 'add') {
    await uploadUniversities();
  } else if (uploadAction == 'clear') {
    await clearAndUploadUniversities();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
