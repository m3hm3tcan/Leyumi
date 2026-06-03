import 'package:flutter/material.dart';
import 'package:babyfeedpro/features/feeding/feeding_screen.dart';
import 'package:babyfeedpro/features/history/history_screen.dart';
import 'package:babyfeedpro/models/baby_profile.dart';
import 'package:babyfeedpro/services/baby_storage.dart';
import 'package:babyfeedpro/widgets/baby_card.dart';
import 'package:babyfeedpro/services/reset_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BabyProfile? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final p = await BabyStorage().loadProfile();

    if (p == null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, "/onboarding");
      });
      return;
    }

    setState(() {
      profile = p;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("BabyFeed Pro"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BabyCard(profile: profile!),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // FEEDING
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FeedingScreen()),
                        );
                      },
                      child: const Text("Start Feeding"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // FEEDING HISTORY
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        );
                      },
                      child: const Text("Feeding History"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // GROWTH UPDATE
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/growth_update");
                      },
                      child: const Text("Growth Update"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // GROWTH HISTORY
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/growth_history");
                      },
                      child: const Text("Growth History"),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ResetService.clearAll();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, "/onboarding");
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Reset App (Clear All Data)"),
            ),
          ],
        ),
      ),
    );
  }
}
