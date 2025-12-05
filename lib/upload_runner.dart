import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'unis/example.dart' show uploadUniversities, clearAndUploadUniversities;

/// Small runner to upload sample universities without launching the UI.
/// Usage:
/// flutter run -d windows -t lib/upload_runner.dart --dart-define=UPLOAD_ACTION=add
/// or
/// flutter run -d windows -t lib/upload_runner.dart --dart-define=UPLOAD_ACTION=clear
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const action = String.fromEnvironment('UPLOAD_ACTION', defaultValue: 'add');
  try {
    if (action == 'clear') {
      await clearAndUploadUniversities();
    } else {
      await uploadUniversities();
    }
    // Exit the process when done.
    // In flutter run this will stop the app.
    // We don't call runApp to avoid launching the UI.
  } catch (e) {
    // ignore: avoid_print
    print('Upload failed: $e');
  }
}
