import 'package:flutter/material.dart';
import 'package:babyfeedpro/features/feeding/feeding_screen.dart';
import 'package:babyfeedpro/features/history/history_screen.dart';
import 'package:babyfeedpro/models/baby_profile.dart';
import 'package:babyfeedpro/services/baby_storage.dart';
import 'package:babyfeedpro/widgets/baby_card.dart';
import 'package:babyfeedpro/services/reset_service.dart';
import 'package:babyfeedpro/features/history/history_hub_screen.dart';
import 'widgets/home_action_card.dart';
import 'package:babyfeedpro/l10n/app_localizations.dart';

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
    final t = AppLocalizations.of(context); // 👈 KISALTMA

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      appBar: AppBar(
        title: Text(t.appTitle), // 👈 DİL DESTEKLİ
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
                    title: t.feeding,          // 👈
                    subtitle: t.startSession,  // 👈
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
                    title: t.history,          // 👈
                    subtitle: t.pastFeedings,  // 👈
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryHubScreen()),
                      );
                    },
                  ),

                  HomeActionCard(
                    icon: Icons.baby_changing_station_rounded,
                    title: t.diaper,           // 👈
                    subtitle: t.trackChanges,  // 👈
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/diaper",
                      );
                    },
                  ),

                  HomeActionCard(
                    icon: Icons.monitor_weight_rounded,
                    title: t.growth,           // 👈
                    subtitle: t.updateWeight,  // 👈
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        "/growth_update",
                      );

                      await loadProfile();
                    },
                  ),
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
                  Text(
                    t.dangerZone, // 👈
                    style: const TextStyle(
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
                        final t = AppLocalizations.of(context);

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(t.confirmResetTitle),
                              content: Text(t.confirmResetContent),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text(t.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    t.delete,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          await ResetService.clearAll();
                          if (!mounted) return;
                          Navigator.pushReplacementNamed(context, "/onboarding");
                        }
                      },

                      icon: const Icon(Icons.delete_forever),
                      label: Text(t.resetApp), // 👈
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
