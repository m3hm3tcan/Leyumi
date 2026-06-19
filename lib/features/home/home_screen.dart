import 'package:flutter/material.dart';
import 'package:babyfeedpro/features/feeding/feeding_screen.dart';
import 'package:babyfeedpro/features/history/history_hub_screen.dart';
import 'package:babyfeedpro/models/baby_profile.dart';
import 'package:babyfeedpro/services/baby_storage.dart';
import 'package:babyfeedpro/widgets/baby_card.dart';
import 'package:babyfeedpro/services/reset_service.dart';
import 'package:babyfeedpro/l10n/app_localizations.dart';
import 'package:babyfeedpro/services/diaper_storage.dart';
import 'package:babyfeedpro/services/feeding_storage.dart';

import 'package:provider/provider.dart';
import '../../core/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BabyProfile? profile;
  bool loading = true;
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    loadProfile();

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => opacity = 1);
    });
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

  Future<void> handleReset(BuildContext context) async {
    final t = AppLocalizations.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.confirmResetTitle),
        content: Text(t.confirmResetContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () async => Navigator.pop(context, true),
            child: Text(
              t.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ResetService.clearAll();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/onboarding");
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(t.appTitle),
        centerTitle: true,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "reset") {
                handleReset(context);
              }
            },  
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "reset",
                child: Text(t.resetApp),
              ),
            ],
          )
        ],
      ),

      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: opacity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              BabyCard(profile: profile!),

              const SizedBox(height: 16),

              /// 🆕 TODAY SUMMARY
              const TodaySummaryCard(),

              const SizedBox(height: 20),

              /// QUICK ACTIONS TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.quickActions,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// MODERN GRID
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                  children: [
                    HomeActionCard(
                      icon: Icons.favorite,
                      title: t.feeding,
                      subtitle: t.startSession,
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
                      icon: Icons.history,
                      title: t.history,
                      subtitle: t.pastFeedings,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryHubScreen(),
                          ),
                        );
                      },
                    ),
                    HomeActionCard(
                      icon: Icons.baby_changing_station,
                      title: t.diaper,
                      subtitle: t.trackChanges,
                      onTap: () {
                        Navigator.pushNamed(context, "/diaper");
                      },
                    ),
                    HomeActionCard(
                      icon: Icons.monitor_weight,
                      title: t.growth,
                      subtitle: t.updateWeight,
                      onTap: () async {
                        await Navigator.pushNamed(context, "/growth_update");
                        await loadProfile();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class TodaySummaryCard extends StatefulWidget {
  const TodaySummaryCard({super.key});

  @override
  State<TodaySummaryCard> createState() => _TodaySummaryCardState();
}

class _TodaySummaryCardState extends State<TodaySummaryCard> {
  int feedingCount = 0;
  int diaperCount = 0;
  String lastActivity = "-";

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String formatLast(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    }

    if (diff.inHours < 24) {
      return "${diff.inHours} h ago";
    }

    return "${diff.inDays} d ago";
  }

  Future<void> loadStats() async {
    final feedingSessions =
        await FeedingStorage().loadSessions();

    final diaperEntries =
        await DiaperStorage().loadEntries();

    final todayFeedings = feedingSessions.where(
      (s) => isToday(s.startTime),
    ).toList();

    final todayDiapers = diaperEntries.where(
      (d) => isToday(d.timestamp),
    ).toList();

    final List<DateTime> activities = [];

    activities.addAll(
      todayFeedings.map((e) => e.startTime),
    );

    activities.addAll(
      todayDiapers.map((e) => e.timestamp),
    );

    activities.sort();

    setState(() {
      feedingCount = todayFeedings.length;
      diaperCount = todayDiapers.length;

      if (activities.isNotEmpty) {
        lastActivity =
            formatLast(activities.last);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: theme.brightness ==
                    Brightness.dark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            t.todayActivities,
            style: theme.textTheme.titleMedium
                ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                label: t.feeding,
                value: feedingCount.toString(),
              ),
              _StatItem(
                label: t.diaper,
                value: diaperCount.toString(),
              ),
              _StatItem(
                label: t.last,
                value: lastActivity,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// 🆕 MODERN ACTION CARD
class HomeActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<HomeActionCard> createState() => _HomeActionCardState();
}

class _HomeActionCardState extends State<HomeActionCard> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.96),
      onTapUp: (_) => setState(() => scale = 1),
      onTapCancel: () => setState(() => scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xff6C8EFF), Color(0xff88E0EF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 6),
              )
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, color: Theme.of(context).cardColor, size: 28),
              const Spacer(),
              Text(
                widget.title,
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}