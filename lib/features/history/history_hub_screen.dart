import 'package:flutter/material.dart';
import 'tabs/feeding_tab.dart';
import 'tabs/growth_tab.dart';
import 'widgets/hub_card.dart';

class HistoryHubScreen extends StatelessWidget {
  const HistoryHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// HEADER
              const Text(
                "History Hub",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Track everything about your baby",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              /// GRID
              Expanded(
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                  children: [
                    HubCard(
                      title: "Feeding",
                      icon: Icons.local_drink_rounded,
                      color: const Color(0xff4DA3FF),
                      subtitle: "Milk tracking",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FeedingTab()),
                        );
                      },
                    ),

                    HubCard(
                      title: "Growth",
                      icon: Icons.show_chart_rounded,
                      color: const Color(0xff22C55E),
                      subtitle: "Weight & height",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GrowthTab()),
                        );
                      },
                    ),

                    /// FUTURE READY
                    HubCard(
                      title: "Diaper",
                      icon: Icons.baby_changing_station,
                      color: const Color(0xffF59E0B),
                      subtitle: "Coming soon",
                      onTap: () {},
                    ),

                    HubCard(
                      title: "Sleep",
                      icon: Icons.nightlight_round,
                      color: const Color(0xff8B5CF6),
                      subtitle: "Coming soon",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}