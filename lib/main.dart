import 'package:flutter/material.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/growth/growth_update_screen.dart';
import 'features/growth/growth_history_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  // await prefs.clear(); // 🔥 TÜM LOCAL STORAGE SİLİNİR
  
  runApp(const BabyFeedApp());
}

class BabyFeedApp extends StatelessWidget {
  const BabyFeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BabyFeed Pro",
      initialRoute: "/home",
      routes: {
        "/onboarding": (_) => const OnboardingScreen(),
        "/home": (_) => const HomeScreen(),
        "/growth_update": (_) => const GrowthUpdateScreen(),
        // "/growth_history": (_) => const GrowthHistoryScreen(),
      },
    );
  }
}
