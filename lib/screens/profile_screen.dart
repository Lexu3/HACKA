import 'package:flutter/material.dart';

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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainProfileBlock(context),

                    const SizedBox(height: 30),

                    const Text(
                      "ИЗБРАННЫЕ",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildFavoritesGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(color: Colors.blueAccent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Telary",
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          Row(
            children: [
              const Text(
                "KZ / RU",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 20),

              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- PROFILE MAIN BLOCK ----------------
  Widget _buildMainProfileBlock(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.person_outline,
          color: Colors.blueAccent,
          size: 60,
        ),

        const SizedBox(width: 20),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Имя", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              _infoBox("Елизавета"),

              const SizedBox(height: 20),

              const Text("Почта", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              _infoBox("example@mail.com"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  // ---------------- FAVORITES GRID ----------------
  Widget _buildFavoritesGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,       // ← 3 ячейки в ряд
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,   // форма ячейки
        ),
        itemBuilder: (context, index) {
          return _favoriteItem("assets/univ.jpg", "Университет $index");
        },
      ),
    );
  }

  // ---------------- FAVORITE ITEM ----------------
  Widget _favoriteItem(String img, String title) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // уменьшенная картинка
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              img,
              width: 40,  // уменьшение в 2.5 раза
              height: 40,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
