import 'package:flutter/material.dart';
import 'package:babyfeedpro/features/feeding/feeding_screen.dart';
import 'package:babyfeedpro/features/history/history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BabyFeed Pro"),
        centerTitle: true,
      ),
     body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FeedingScreen()),
              );
            },
            child: const Text("Start Feeding"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HistoryScreen()),
              );
            },
            child: const Text("History"),
          ),
        ],
      ),
    ),
    );
  }
}
