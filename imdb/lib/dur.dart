import 'package:flutter/material.dart';

class PillExample extends StatelessWidget {
  const PillExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(50), // 💊 Oval yapı
        ),
        child: const Text(
          'AI Destekli',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
