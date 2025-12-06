import 'package:flutter/material.dart';

class AppTheme {
  // Palette inspired by the attachment (greens/teals)
  static const Color greenDark = Color(0xFF0F6B4A);
  static const Color greenMid = Color(0xFF197A63);
  static const Color greenLight = Color(0xFFBFEBD7);
  static const Color accent = Color(0xFF0A8A6B);

  static Gradient mainGradient = const LinearGradient(
    colors: [Color(0xFFBFEBD7), Color(0xFF197A63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData themeData() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: greenMid,
      colorScheme: ColorScheme.fromSeed(seedColor: greenMid, primary: greenMid),
      scaffoldBackgroundColor: greenLight,
      textTheme: base.textTheme.apply(bodyColor: Colors.black87, displayColor: Colors.black87),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
