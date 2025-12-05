import 'package:flutter/material.dart';
import 'package:nova/screens/home_page.dart';
import 'main_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildUniversitiesGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------- HEADER -----------------------------

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ЛОГО (ИКОНКА) — увеличено до 250
          SizedBox(
            height: 250,
            width: 250,
            child: Image.asset(
              "assets/icon.png",
              fit: BoxFit.contain,
            ),
          ),

          const Spacer(),

          // СЛОВО TELARY — ССЫЛКА на main_screen.dart
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
              );
            },
            child: const Text(
              "Telary",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ----------------------- GRID из 3 в ряд ------------------------

  Widget _buildUniversitiesGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3, // ← 3 в строке
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _universityCard("Harvard University", "assets/un1.png"),
        _universityCard("Oxford University", "assets/un2.png"),
        _universityCard("MIT", "assets/un3.png"),
        _universityCard("Cambridge University", "assets/un4.png"),
        _universityCard("Stanford University", "assets/un5.png"),
        _universityCard("Columbia University", "assets/un6.png"),
      ],
    );
  }

  // --------------------- КАРТОЧКА УНИВЕРА -------------------------

  Widget _universityCard(String title, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDFF3FF), // светло-голубой фон
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),

      child: Column(
        children: [
          // Картинка уменьшена в 2.5 раза (предположительно)
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
