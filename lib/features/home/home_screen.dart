import 'package:flutter/material.dart';
import 'package:babyfeedpro/features/feeding/feeding_screen.dart';
import 'package:babyfeedpro/features/history/history_screen.dart';
import 'package:babyfeedpro/models/baby_profile.dart';
import 'package:babyfeedpro/services/baby_storage.dart';
import 'package:babyfeedpro/widgets/baby_card.dart';
import 'package:babyfeedpro/services/reset_service.dart';
import 'package:babyfeedpro/features/history/history_hub_screen.dart';
// 👇 yeni widget
import 'widgets/home_action_card.dart';

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
      backgroundColor: const Color(0xffF6F7FB),

      appBar: AppBar(
        title: const Text("BabyFeed Pro"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            BabyCard(profile: profile!),

            const SizedBox(height: 16),

            // ─────────────────────────────
            // QUICK ACTION GRID
            // ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  HomeActionCard(
                    icon: Icons.favorite_rounded,
                    title: "Feeding",
                    subtitle: "Start session",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeedingScreen(),
                        ),
                      );
                    },
                  ),

                  HomeActionCard(
                    icon: Icons.history_rounded,
                    title: "History",
                    subtitle: "Past feedings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryHubScreen()),
                      );
                    },
                  ),

                  HomeActionCard(
                    icon: Icons.monitor_weight_rounded,
                    title: "Growth",
                    subtitle: "Update weight",
                    onTap: () {
                      Navigator.pushNamed(context, "/growth_update");
                    },
                  ),

                  // HomeActionCard(
                  //   icon: Icons.show_chart_rounded,
                  //   title: "Growth Log",
                  //   subtitle: "Measurements",
                  //   onTap: () {
                  //     Navigator.pushNamed(context, "/growth_history");
                  //   },
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ─────────────────────────────
            // DANGER ZONE
            // ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Danger Zone",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        await ResetService.clearAll();
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(
                          context,
                          "/onboarding",
                        );
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text("Reset App (Clear All Data)"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}