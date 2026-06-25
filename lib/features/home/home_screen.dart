import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/premium/premium_access.dart';
import '../../core/premium/premium_feature.dart';
import '../../core/child/active_child_aware.dart';
import '../../core/child/active_child_provider.dart';
import '../../core/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/baby_profile.dart';
import '../../services/reset_service.dart';
import '../../widgets/baby_card.dart';
import '../feeding/feeding_screen.dart';
import '../history/history_hub_screen.dart';
import '../milk_inventory/milk_inventory_screen.dart';
import '../children/child_management_screen.dart';
import 'widgets/home_action_card.dart';
import 'widgets/live_feeding_home_card.dart';
import 'widgets/today_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, ActiveChildAware<HomeScreen> {
  BabyProfile? _profile;
  bool _loading = true;
  double _opacity = 0;
  int _dashboardRefreshVersion = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _opacity = 1);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshDashboard();
  }

  Future<void> _loadProfile() async {
    final children = context.read<ActiveChildProvider>();
    await children.ensureLoaded();
    final profile = children.activeChild;
    if (!mounted) return;

    if (profile == null) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    setState(() {
      _profile = profile;
      _loading = false;
      _dashboardRefreshVersion++;
    });
  }

  @override
  Future<void> onActiveChildChanged() => _loadProfile();

  void _refreshDashboard() {
    if (!mounted) return;
    setState(() => _dashboardRefreshVersion++);
  }

  Future<void> _handleReset() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmResetTitle),
        content: Text(l10n.confirmResetContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ResetService.clearAll();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: _buildAppBar(l10n),
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: _opacity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              BabyCard(profile: _profile!),
              const SizedBox(height: 4),
              TodaySummaryCard(refreshVersion: _dashboardRefreshVersion),
              const SizedBox(height: 12),
              LiveFeedingHomeCard(refreshVersion: _dashboardRefreshVersion),
              const SizedBox(height: 16),
              _buildQuickActionsTitle(l10n),
              const SizedBox(height: 10),
              _buildQuickActions(l10n),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
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
                l10n.appTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              Text(
                l10n.appSubtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(166),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: l10n.switchChild,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChildManagementScreen()),
            );
            await _loadProfile();
            _refreshDashboard();
          },
          icon: const Icon(Icons.switch_account_rounded),
        ),
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
            if (value == 'reset') _handleReset();
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'reset', child: Text(l10n.resetApp)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsTitle(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          l10n.quickActions,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withAlpha(180),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 12.0;
          final compactWidth = (constraints.maxWidth - gap) / 2;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              _compactAction(
                width: compactWidth,
                icon: Icons.favorite_rounded,
                title: l10n.feeding,
                subtitle: l10n.startSession,
                colors: const [Color(0xffF26B8A), Color(0xffFF9A8B)],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedingScreen()),
                  );
                  _refreshDashboard();
                },
              ),
              _compactAction(
                width: compactWidth,
                icon: Icons.inventory_2_rounded,
                title: l10n.milkInventory,
                subtitle: l10n.premiumMilkInventory,
                colors: const [Color(0xff5687E8), Color(0xff72C6EF)],
                isPremium: true,
                onTap: () {
                  PremiumAccess.open(
                    context,
                    feature: PremiumFeature.milkInventory,
                    builder: (_) => const MilkInventoryScreen(),
                  );
                },
              ),
              _compactAction(
                width: compactWidth,
                icon: Icons.baby_changing_station_rounded,
                title: l10n.diaper,
                subtitle: l10n.trackChanges,
                colors: const [Color(0xff38AFA9), Color(0xff6DD5C3)],
                onTap: () async {
                  await Navigator.pushNamed(context, '/diaper');
                  _refreshDashboard();
                },
              ),
              _compactAction(
                width: compactWidth,
                icon: Icons.monitor_weight_rounded,
                title: l10n.growth,
                subtitle: l10n.updateWeight,
                colors: const [Color(0xffED8A52), Color(0xffF6BD60)],
                onTap: () async {
                  await Navigator.pushNamed(context, '/growth_update');
                  await context.read<ActiveChildProvider>().reload();
                  await _loadProfile();
                },
              ),
              SizedBox(
                width: constraints.maxWidth,
                height: 88,
                child: HomeActionCard(
                  icon: Icons.history_rounded,
                  title: l10n.history,
                  subtitle: l10n.pastFeedings,
                  colors: const [Color(0xff7568C9), Color(0xffA78BDA)],
                  isWide: true,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HistoryHubScreen(),
                      ),
                    );
                    _refreshDashboard();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _compactAction({
    required double width,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return SizedBox(
      width: width,
      height: 112,
      child: HomeActionCard(
        icon: icon,
        title: title,
        subtitle: subtitle,
        colors: colors,
        isPremium: isPremium,
        onTap: onTap,
      ),
    );
  }
}
