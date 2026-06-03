import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const BabyFeedProApp());
}

class BabyFeedProApp extends StatelessWidget {
  const BabyFeedProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
