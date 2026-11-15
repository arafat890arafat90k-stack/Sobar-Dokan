import 'package:flutter/material.dart';

void main() {
  runApp(const SobarDokanApp());
}

class SobarDokanApp extends StatelessWidget {
  const SobarDokanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sobar Dokan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobar Dokan - সবার দোকান'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.storefront, size: 80, color: Colors.green),
          const SizedBox(height: 10),
          const Center(child: Text('সবার দোকান', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _item('Chal', 'চাল', Icons.rice_bowl),
              _item('Dal', 'ডাল', Icons.bubble_chart),
              _item('Oil', 'তেল', Icons.water_drop),
              _item('Spice', 'মসলা', Icons.spa),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(String en, String bn, IconData icon) {
    return Card(
      elevation: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.green),
          const SizedBox(height: 8),
          Text('$en\n$bn', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
