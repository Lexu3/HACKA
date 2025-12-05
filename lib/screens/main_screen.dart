import 'package:flutter/material.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? region;
  String? city;
  String? education;
  String? direction;
  String? reality;

  bool intlYes = false;
  bool intlNo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildFilters(),
                  ),

                  Expanded(
                    flex: 1,
                    child: _buildChatBot(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Telary – слоган",
            style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
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
          )
        ],
      ),
    );
  }

  // ---------------- FILTERS ----------------

  Widget _buildFilters() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _drop("Область", region, ["Алматы", "Астана"], (v) => setState(() => region = v)),
          const SizedBox(height: 16),

          _drop("Город", city, ["Алматы", "Астана"], (v) => setState(() => city = v)),
          const SizedBox(height: 16),

          _drop("Уровень образования", education, ["Бакалавр", "Магистратура"], (v) => setState(() => education = v)),
          const SizedBox(height: 16),

          _drop("Направление", direction, ["IT", "Экономика", "Педагогика"], (v) => setState(() => direction = v)),
          const SizedBox(height: 16),

          _drop("Реалити", reality, ["Грант", "Платно"], (v) => setState(() => reality = v)),
          const SizedBox(height: 22),

          Row(
            children: [
              const Text("Междунар. сотрудничество:", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 16),

              Checkbox(
                value: intlYes,
                onChanged: (value) {
                  setState(() {
                    intlYes = value!;
                    if (value) intlNo = false;
                  });
                },
              ),
              const Text("Да"),

              Checkbox(
                value: intlNo,
                onChanged: (value) {
                  setState(() {
                    intlNo = value!;
                    if (value) intlYes = false;
                  });
                },
              ),
              const Text("Нет"),
            ],
          ),

          const SizedBox(height: 30),

          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () {},
              child: const Text(
                "НАЙТИ",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable dropdown widget
  Widget _drop(String title, String? value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(border: InputBorder.none),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // ---------------- CHAT BOT ----------------

  Widget _buildChatBot() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ЧАТ БОТ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            height: 300,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text("чем вам помочь?"),
          ),

          const SizedBox(height: 20),

          TextField(
            decoration: InputDecoration(
              hintText: "Введите сообщение...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }
}
