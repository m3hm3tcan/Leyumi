import 'dart:async';

import 'package:flutter/material.dart';
import 'package:leyumi/core/premium/premium_access.dart';
import 'package:leyumi/core/premium/premium_feature.dart';
import 'package:leyumi/features/feeding/feeding_screen.dart';
import 'package:leyumi/features/history/history_hub_screen.dart';
import 'package:leyumi/features/milk_inventory/milk_inventory_screen.dart';
import 'package:leyumi/models/baby_profile.dart';
import 'package:leyumi/services/baby_storage.dart';
import 'package:leyumi/widgets/baby_card.dart';
import 'package:leyumi/services/reset_service.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:leyumi/services/diaper_storage.dart';
import 'package:leyumi/services/feeding_storage.dart';

import 'package:provider/provider.dart';
import '../../core/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<_TodaySummaryCardState> _todaySummaryKey =
      GlobalKey<_TodaySummaryCardState>();
  final GlobalKey<_LiveFeedingHomeCardState> _liveFeedingKey =
      GlobalKey<_LiveFeedingHomeCardState>();

  BabyProfile? profile;
  bool loading = true;
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadProfile();

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => opacity = 1);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
      _liveFeedingKey.currentState?.refresh();
    }
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icon/app_icon_foreground.png',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.appTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  t.appSubtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
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
              TodaySummaryCard(key: _todaySummaryKey),

              const SizedBox(height: 12),

              LiveFeedingHomeCard(key: _liveFeedingKey),

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
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedingScreen(),
                          ),
                        );
                        await _todaySummaryKey.currentState?.loadStats();
                        await _liveFeedingKey.currentState?.refresh();
                      },
                    ),
                    HomeActionCard(
                      icon: Icons.history,
                      title: t.history,
                      subtitle: t.pastFeedings,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryHubScreen(),
                          ),
                        );
                        await _todaySummaryKey.currentState?.loadStats();
                      },
                    ),
                    HomeActionCard(
                      icon: Icons.inventory_2_rounded,
                      title: t.milkInventory,
                      subtitle: t.premiumMilkInventory,
                      isPremium: true,
                      onTap: () {
                        PremiumAccess.open(
                          context,
                          feature: PremiumFeature.milkInventory,
                          builder: (_) => const MilkInventoryScreen(),
                        );
                      },
                    ),
                    HomeActionCard(
                      icon: Icons.baby_changing_station,
                      title: t.diaper,
                      subtitle: t.trackChanges,
                      onTap: () async {
                        await Navigator.pushNamed(context, "/diaper");
                        await _todaySummaryKey.currentState?.loadStats();
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
    final feedingSessions = await FeedingStorage().loadSessions();

    final diaperEntries = await DiaperStorage().loadEntries();

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

    if (!mounted) return;

    setState(() {
      feedingCount = todayFeedings.length;
      diaperCount = todayDiapers.length;
      lastActivity =
          activities.isNotEmpty ? formatLast(activities.last) : "-";
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
class LiveFeedingHomeCard extends StatefulWidget {
  const LiveFeedingHomeCard({super.key});

  @override
  State<LiveFeedingHomeCard> createState() => _LiveFeedingHomeCardState();
}

class _LiveFeedingHomeCardState extends State<LiveFeedingHomeCard> {
  Timer? _timer;
  Map<String, dynamic>? _draft;

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _draft != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final draft = await FeedingStorage().loadActiveDraft();
    if (!mounted) return;
    setState(() {
      _draft = draft;
    });
  }

  Future<void> refresh() => _loadDraft();

  String _format(Duration duration) {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    if (_draft == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final activeSide = _draft!["activeSide"] as String?;
    final activeStartedAtRaw = _draft!["activeSideStartedAt"] as String?;
    final startedAt = activeStartedAtRaw == null
        ? null
        : DateTime.tryParse(activeStartedAtRaw);
    final elapsed = startedAt == null
        ? Duration.zero
        : DateTime.now().difference(startedAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffFF8A65), Color(0xffFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.08),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.timer_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Live feeding devam ediyor",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activeSide == null
                      ? "Kaydedilmemis feeding taslagi hazir"
                      : "${activeSide == "left" ? "Sol" : "Sag"} taraf - ${_format(elapsed)}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FeedingScreen(),
                ),
              );
              await _loadDraft();
            },
            child: Text(
              "Ac",
              style: TextStyle(
                color: theme.cardColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPremium;

  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPremium = false,
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
              Row(
                children: [
                  Icon(
                    widget.icon,
                    color: Theme.of(context).cardColor,
                    size: 28,
                  ),
                  const Spacer(),
                  if (widget.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
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
