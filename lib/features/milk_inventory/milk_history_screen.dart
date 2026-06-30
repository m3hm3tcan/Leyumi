import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:leyumi/core/premium/premium_feature.dart';
import 'package:leyumi/core/premium/premium_provider.dart';
import 'package:leyumi/features/milk_inventory/milk_batch.dart';
import 'package:leyumi/features/milk_inventory/milk_inventory_event.dart';
import 'package:leyumi/features/premium/premium_paywall_screen.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:leyumi/services/milk_inventory_storage.dart';
import 'package:provider/provider.dart';

import '../../core/child/active_child_aware.dart';
import '../history/widgets/history_page_shell.dart';

class MilkHistoryScreen extends StatefulWidget {
  const MilkHistoryScreen({super.key});

  @override
  State<MilkHistoryScreen> createState() => _MilkHistoryScreenState();
}

class _MilkHistoryScreenState extends State<MilkHistoryScreen>
    with ActiveChildAware<MilkHistoryScreen> {
  final _storage = MilkInventoryStorage();
  List<MilkInventoryEvent> _events = [];
  List<MilkBatch> _batches = [];
  bool _loading = true;
  int _tabIndex = 0;

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final events = await _storage.loadEvents();
    final batches = await _storage.loadBatches();
    events.sort((a, b) => b.eventAt.compareTo(a.eventAt));
    if (!mounted) return;
    setState(() {
      _events = events;
      _batches = batches;
      _loading = false;
    });
  }

  @override
  Future<void> onActiveChildChanged() => _load();

  int get _totalUsed => _events
      .where((event) => event.type == MilkInventoryEventType.used)
      .fold(0, (sum, event) => sum + event.amountMl);

  int get _totalDiscarded => _events
      .where((event) => event.type == MilkInventoryEventType.discarded)
      .fold(0, (sum, event) => sum + event.amountMl);

  int get _remainingStock => _batches
      .where((batch) => batch.isActive)
      .fold(0, (sum, batch) => sum + batch.remainingAmountMl);

  DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

  List<DateTime> get _chartDays {
    final today = _day(DateTime.now());
    return List.generate(
      14,
      (index) => today.subtract(Duration(days: 13 - index)),
    );
  }

  Map<DateTime, int> _dailyTotal(MilkInventoryEventType type) {
    final result = <DateTime, int>{};
    for (final event in _events.where((event) => event.type == type)) {
      final day = _day(event.eventAt);
      result[day] = (result[day] ?? 0) + event.amountMl;
    }
    return result;
  }

  List<FlSpot> get _stockSpots {
    final chronological = _events.reversed.toList();
    return List.generate(_chartDays.length, (index) {
      final endOfDay = _chartDays[index].add(const Duration(days: 1));
      var stock = 0;
      for (final event in chronological) {
        if (!event.eventAt.isBefore(endOfDay)) continue;
        stock += _stockDelta(event);
      }
      return FlSpot(index.toDouble(), math.max(0, stock).toDouble());
    });
  }

  int _stockDelta(MilkInventoryEvent event) {
    if (event.type == MilkInventoryEventType.created) {
      return event.amountMl;
    }
    if (event.type == MilkInventoryEventType.used ||
        event.type == MilkInventoryEventType.discarded) {
      return -event.amountMl;
    }
    if (event.type == MilkInventoryEventType.corrected) {
      return event.amountMl;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final premium = context.watch<PremiumProvider>();

    if (!premium.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!premium.hasAccess(PremiumFeature.milkInventory)) {
      return const PremiumPaywallScreen(feature: PremiumFeature.milkInventory);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.milkHistory)),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xff111827), Color(0xff0B1120)]
                : [
                    const Color(0xff7C5CE7).withAlpha(18),
                    theme.scaffoldBackgroundColor,
                  ],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: _summary(l10n),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _tabBar(l10n),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _tabIndex == 0
                        ? _activityList(l10n)
                        : _insights(l10n),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _summary(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff6257D9), Color(0xff9A67DC)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff6257D9).withAlpha(55),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(l10n.remainingMilk, '$_remainingStock ml'),
          ),
          _divider(),
          Expanded(child: _summaryItem(l10n.usedMilk, '$_totalUsed ml')),
          _divider(),
          Expanded(
            child: _summaryItem(l10n.discardedMilk, '$_totalDiscarded ml'),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withAlpha(190),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 32,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: Colors.white.withAlpha(40),
  );

  Widget _tabBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withAlpha(220),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              Theme.of(context).brightness == Brightness.dark ? 25 : 7,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(children: [_tab(l10n.activity, 0), _tab(l10n.insights, 1)]),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xff6257D9).withAlpha(28)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? const Color(0xff6257D9) : null,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _activityList(AppLocalizations l10n) {
    if (_events.isEmpty) {
      return HistoryEmptyState(
        icon: Icons.local_drink_rounded,
        color: const Color(0xff6257D9),
        title: l10n.noMilkHistory,
        subtitle: l10n.usedAndRemainingMilk,
      );
    }

    final grouped = <DateTime, List<MilkInventoryEvent>>{};
    for (final event in _events) {
      grouped.putIfAbsent(_day(event.eventAt), () => []).add(event);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        for (final group in grouped.entries) ...[
          HistorySectionTitle(
            title: MaterialLocalizations.of(
              context,
            ).formatMediumDate(group.key),
            count: group.value.length,
            countLabel: l10n.activity.toLowerCase(),
            color: const Color(0xff6257D9),
          ),
          for (final event in group.value) _eventCard(event, l10n),
        ],
      ],
    );
  }

  Widget _eventCard(MilkInventoryEvent event, AppLocalizations l10n) {
    final presentation = _eventPresentation(event, l10n);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(event.eventAt));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withAlpha(
          Theme.of(context).brightness == Brightness.dark ? 220 : 250,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: presentation.color.withAlpha(38)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              Theme.of(context).brightness == Brightness.dark ? 34 : 9,
            ),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: presentation.color.withAlpha(22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(presentation.icon, color: presentation.color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${event.labelNumber} · ${presentation.title}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  presentation.detail,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withAlpha(165),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _insights(AppLocalizations l10n) {
    if (_events.isEmpty) {
      return HistoryEmptyState(
        icon: Icons.insights_rounded,
        color: const Color(0xff6257D9),
        title: l10n.noMilkHistory,
        subtitle: l10n.insights,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      children: [
        _chartCard(
          title: l10n.dailyMilkMovement,
          subtitle: l10n.last14Days,
          child: _movementChart(l10n),
        ),
        _chartCard(
          title: l10n.stockOverTime,
          subtitle: l10n.last14Days,
          child: _stockChart(),
        ),
      ],
    );
  }

  Widget _movementChart(AppLocalizations l10n) {
    final added = _dailyTotal(MilkInventoryEventType.created);
    final used = _dailyTotal(MilkInventoryEventType.used);
    final groups = List.generate(_chartDays.length, (index) {
      final day = _chartDays[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (added[day] ?? 0).toDouble(),
            color: const Color(0xff6D63E8),
            width: 6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: (used[day] ?? 0).toDouble(),
            color: const Color(0xff45B887),
            width: 6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
    final maxY = math
        .max(50, [...added.values, ...used.values].fold<int>(0, math.max))
        .toDouble();

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: maxY,
              barGroups: groups,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Theme.of(context).dividerColor.withAlpha(45),
                  dashArray: const [4, 5],
                ),
              ),
              titlesData: _titles(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legend(const Color(0xff6D63E8), l10n.addedMilk),
            const SizedBox(width: 18),
            _legend(const Color(0xff45B887), l10n.usedMilk),
          ],
        ),
      ],
    );
  }

  Widget _stockChart() {
    final maxY = math
        .max(
          50,
          _stockSpots.fold<double>(0, (max, spot) => math.max(max, spot.y)),
        )
        .toDouble();
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 13,
          minY: 0,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Theme.of(context).dividerColor.withAlpha(45),
              dashArray: const [4, 5],
            ),
          ),
          titlesData: _titles(),
          lineBarsData: [
            LineChartBarData(
              spots: _stockSpots,
              isCurved: true,
              color: const Color(0xff6D63E8),
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xff6D63E8).withAlpha(28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlTitlesData _titles() {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 38,
          getTitlesWidget: (value, meta) {
            if (value == meta.max) return const SizedBox();
            return SideTitleWidget(
              meta: meta,
              child: Text(
                value.round().toString(),
                style: const TextStyle(fontSize: 9),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final index = value.round();
            if (index < 0 || index >= _chartDays.length || index % 3 != 0) {
              return const SizedBox();
            }
            return SideTitleWidget(
              meta: meta,
              child: Text(
                MaterialLocalizations.of(
                  context,
                ).formatShortDate(_chartDays[index]),
                style: const TextStyle(fontSize: 8),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _chartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withAlpha(
          Theme.of(context).brightness == Brightness.dark ? 220 : 250,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              Theme.of(context).brightness == Brightness.dark ? 34 : 9,
            ),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withAlpha(150),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 10)),
    ],
  );

  ({String title, String detail, IconData icon, Color color})
  _eventPresentation(MilkInventoryEvent event, AppLocalizations l10n) {
    switch (event.type) {
      case MilkInventoryEventType.created:
        return (
          title: l10n.milkAdded,
          detail:
              '${event.amountMl} ml · ${event.remainingAfterMl} ml '
              '${l10n.remaining.toLowerCase()}',
          icon: Icons.add_rounded,
          color: const Color(0xff6D63E8),
        );
      case MilkInventoryEventType.used:
        return (
          title: l10n.usedMilk,
          detail:
              '${event.amountMl} ml · ${event.remainingAfterMl} ml '
              '${l10n.remaining.toLowerCase()}',
          icon: Icons.local_drink_rounded,
          color: const Color(0xff45B887),
        );
      case MilkInventoryEventType.discarded:
        return (
          title: l10n.discardedMilk,
          detail:
              '${event.amountMl} ml · ${event.remainingAfterMl} ml '
              '${l10n.remaining.toLowerCase()}',
          icon: Icons.delete_sweep_rounded,
          color: Colors.orange,
        );
      case MilkInventoryEventType.movedToFreezer:
        return (
          title: l10n.movedToFreezer,
          detail: '${event.remainingAfterMl} ml',
          icon: Icons.ac_unit_rounded,
          color: Colors.lightBlue,
        );
      case MilkInventoryEventType.corrected:
        return (
          title: l10n.recordCorrected,
          detail:
              '${event.remainingAfterMl} ml ${l10n.remaining.toLowerCase()}',
          icon: Icons.edit_rounded,
          color: Colors.blueGrey,
        );
    }
  }
}
