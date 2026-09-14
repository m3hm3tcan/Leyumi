import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/diaper/diaper_entry.dart';
import '../../features/home/preferences/home_preferences.dart';
import '../../features/home/preferences/home_preferences_provider.dart';
import '../../l10n/app_localizations.dart';

class HomeCustomizationScreen extends StatefulWidget {
  const HomeCustomizationScreen({super.key});

  @override
  State<HomeCustomizationScreen> createState() =>
      _HomeCustomizationScreenState();
}

class _HomeCustomizationScreenState extends State<HomeCustomizationScreen> {
  bool _busy = false;

  Future<void> _perform(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).operationFailed)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<HomePreferencesProvider>();
    final preferences = provider.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.customizeHomeTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _IntroCard(l10n: l10n),
          const SizedBox(height: 18),
          _SectionTitle(
            title: l10n.homeInformationCards,
            subtitle: l10n.homeInformationCardsSubtitle,
          ),
          const SizedBox(height: 10),
          _PreferenceGroup(
            children: [
              for (
                var index = 0;
                index < preferences.dashboardOrder.length;
                index++
              )
                _PreferenceRow(
                  key: ValueKey(preferences.dashboardOrder[index]),
                  icon: _dashboardIcon(preferences.dashboardOrder[index]),
                  color: _dashboardColor(preferences.dashboardOrder[index]),
                  title: _dashboardTitle(
                    preferences.dashboardOrder[index],
                    l10n,
                  ),
                  visible: preferences.visibleDashboardCards.contains(
                    preferences.dashboardOrder[index],
                  ),
                  enabled: !_busy,
                  canMoveUp: index > 0,
                  canMoveDown: index < preferences.dashboardOrder.length - 1,
                  onVisibilityChanged: (visible) => _perform(
                    () => provider.setDashboardVisible(
                      preferences.dashboardOrder[index],
                      visible,
                    ),
                  ),
                  onMoveUp: () => _perform(
                    () => provider.moveDashboard(
                      preferences.dashboardOrder[index],
                      -1,
                    ),
                  ),
                  onMoveDown: () => _perform(
                    () => provider.moveDashboard(
                      preferences.dashboardOrder[index],
                      1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(
            title: l10n.homeQuickActions,
            subtitle: l10n.homeQuickActionsSubtitle,
          ),
          const SizedBox(height: 10),
          _PreferenceGroup(
            children: [
              for (
                var index = 0;
                index < preferences.quickActionOrder.length;
                index++
              )
                _PreferenceRow(
                  key: ValueKey(preferences.quickActionOrder[index]),
                  icon: _quickActionIcon(preferences.quickActionOrder[index]),
                  color: _quickActionColor(preferences.quickActionOrder[index]),
                  title: _quickActionTitle(
                    preferences.quickActionOrder[index],
                    l10n,
                  ),
                  visible: preferences.visibleQuickActions.contains(
                    preferences.quickActionOrder[index],
                  ),
                  enabled: !_busy,
                  canMoveUp: index > 0,
                  canMoveDown: index < preferences.quickActionOrder.length - 1,
                  onVisibilityChanged: (visible) => _perform(
                    () => provider.setQuickActionVisible(
                      preferences.quickActionOrder[index],
                      visible,
                    ),
                  ),
                  onMoveUp: () => _perform(
                    () => provider.moveQuickAction(
                      preferences.quickActionOrder[index],
                      -1,
                    ),
                  ),
                  onMoveDown: () => _perform(
                    () => provider.moveQuickAction(
                      preferences.quickActionOrder[index],
                      1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle(
            title: l10n.defaultQuickDiaperType,
            subtitle: l10n.defaultQuickDiaperTypeSubtitle,
          ),
          const SizedBox(height: 10),
          _PreferenceGroup(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<DiaperType>(
                    segments: [
                      ButtonSegment(
                        value: DiaperType.pee,
                        icon: const Icon(Icons.water_drop_rounded, size: 18),
                        label: Text(l10n.quickWet),
                      ),
                      ButtonSegment(
                        value: DiaperType.poop,
                        icon: const Icon(Icons.circle_rounded, size: 18),
                        label: Text(l10n.quickDirty),
                      ),
                      ButtonSegment(
                        value: DiaperType.both,
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: Text(l10n.quickBoth),
                      ),
                    ],
                    selected: {preferences.preferredQuickDiaperType},
                    onSelectionChanged: _busy
                        ? null
                        : (selection) => _perform(
                            () => provider.setPreferredQuickDiaperType(
                              selection.single,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () => _perform(() async {
                    await provider.resetToDefaults();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.homeLayoutReset)),
                    );
                  }),
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(l10n.restoreDefaultLayout),
          ),
        ],
      ),
    );
  }

  String _dashboardTitle(HomeDashboardCard card, AppLocalizations l10n) =>
      switch (card) {
        HomeDashboardCard.todaySummary => l10n.todayAtAGlance,
        HomeDashboardCard.quickDiaper => l10n.quickDiaperTitle,
        HomeDashboardCard.upcomingCare => l10n.upcomingCare,
      };

  IconData _dashboardIcon(HomeDashboardCard card) => switch (card) {
    HomeDashboardCard.todaySummary => Icons.auto_awesome_rounded,
    HomeDashboardCard.quickDiaper => Icons.bolt_rounded,
    HomeDashboardCard.upcomingCare => Icons.event_available_rounded,
  };

  Color _dashboardColor(HomeDashboardCard card) => switch (card) {
    HomeDashboardCard.todaySummary => const Color(0xff725DE2),
    HomeDashboardCard.quickDiaper => const Color(0xff38AFA9),
    HomeDashboardCard.upcomingCare => const Color(0xff5B6CFF),
  };

  String _quickActionTitle(HomeQuickAction action, AppLocalizations l10n) =>
      switch (action) {
        HomeQuickAction.feeding => l10n.feeding,
        HomeQuickAction.milkInventory => l10n.milkInventory,
        HomeQuickAction.diaper => l10n.diaper,
        HomeQuickAction.growth => l10n.growth,
        HomeQuickAction.careCalendar => l10n.careCalendar,
        HomeQuickAction.history => l10n.history,
      };

  IconData _quickActionIcon(HomeQuickAction action) => switch (action) {
    HomeQuickAction.feeding => Icons.favorite_rounded,
    HomeQuickAction.milkInventory => Icons.inventory_2_rounded,
    HomeQuickAction.diaper => Icons.baby_changing_station_rounded,
    HomeQuickAction.growth => Icons.monitor_weight_rounded,
    HomeQuickAction.careCalendar => Icons.calendar_month_rounded,
    HomeQuickAction.history => Icons.history_rounded,
  };

  Color _quickActionColor(HomeQuickAction action) => switch (action) {
    HomeQuickAction.feeding => const Color(0xffF26B8A),
    HomeQuickAction.milkInventory => const Color(0xff5687E8),
    HomeQuickAction.diaper => const Color(0xff38AFA9),
    HomeQuickAction.growth => const Color(0xffED8A52),
    HomeQuickAction.careCalendar => const Color(0xff5B6CFF),
    HomeQuickAction.history => const Color(0xff7568C9),
  };
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff665BE7), Color(0xff9A65D7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff725DE2).withAlpha(40),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.yourHomeYourWay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.customizeHomeIntro,
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(155),
          ),
        ),
      ],
    );
  }
}

class _PreferenceGroup extends StatelessWidget {
  const _PreferenceGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(55)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index < children.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.visible,
    required this.enabled,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onVisibilityChanged,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final IconData icon;
  final Color color;
  final String title;
  final bool visible;
  final bool enabled;
  final bool canMoveUp;
  final bool canMoveDown;
  final ValueChanged<bool> onVisibilityChanged;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: visible ? 1 : .58,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 6, 7),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: l10n.moveUp,
              onPressed: enabled && canMoveUp ? onMoveUp : null,
              icon: const Icon(Icons.keyboard_arrow_up_rounded),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: l10n.moveDown,
              onPressed: enabled && canMoveDown ? onMoveDown : null,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              visualDensity: VisualDensity.compact,
            ),
            Switch(
              value: visible,
              onChanged: enabled ? onVisibilityChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}
