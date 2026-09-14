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
import '../history/graphs/graph_style.dart';
import '../history/widgets/history_page_shell.dart';

class MilkHistoryScreen extends StatefulWidget {
  const MilkHistoryScreen({super.key});

  @override
  State<MilkHistoryScreen> createState() => _MilkHistoryScreenState();
}

class _MilkHistoryScreenState extends State<MilkHistoryScreen>
    with ActiveChildAware<MilkHistoryScreen> {
  static const _addedColor = Color(0xff6D63E8);
  static const _usedColor = Color(0xff45B887);

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
        PremiumChartCard(
          title: l10n.dailyMilkMovement,
          subtitle: '${l10n.last14Days} · ${l10n.tapChartPointForDetails}',
          trailing: GraphLegend(
            items: [(_addedColor, l10n.addedMilk), (_usedColor, l10n.usedMilk)],
            alignment: WrapAlignment.end,
          ),
          child: _movementChart(l10n),
        ),
        PremiumChartCard(
          title: l10n.stockOverTime,
          subtitle: '${l10n.last14Days} · ${l10n.tapChartPointForDetails}',
          trailing: _valuePill('$_remainingStock ml', _addedColor),
          child: _stockChart(l10n),
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
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [_addedColor.withAlpha(190), _addedColor],
            ),
            width: 7,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
          BarChartRodData(
            toY: (used[day] ?? 0).toDouble(),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [_usedColor.withAlpha(190), _usedColor],
            ),
            width: 7,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ],
      );
    });
    final maxY = chartMaximum(
      [...added.values, ...used.values].map((value) => value.toDouble()),
      minimum: 50,
    );
    final interval = niceInterval(maxY);

    return SizedBox(
      height: 230,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          barGroups: groups,
          borderData: FlBorderData(show: false),
          gridData: premiumGrid(context, interval: interval),
          titlesData: _titles(interval),
          barTouchData: _movementTouchData(l10n),
        ),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Widget _stockChart(AppLocalizations l10n) {
    final maxY = chartMaximum(_stockSpots.map((spot) => spot.y), minimum: 50);
    final interval = niceInterval(maxY);
    return SizedBox(
      height: 230,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 13,
          minY: 0,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          gridData: premiumGrid(context, interval: interval),
          titlesData: _titles(interval),
          lineTouchData: _stockTouchData(l10n),
          lineBarsData: [
            LineChartBarData(
              spots: _stockSpots,
              isCurved: true,
              curveSmoothness: .2,
              preventCurveOverShooting: true,
              color: _addedColor,
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: index == _stockSpots.length - 1 ? 4.5 : 3,
                      color: Theme.of(context).cardColor,
                      strokeWidth: 2.5,
                      strokeColor: _addedColor,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_addedColor.withAlpha(58), _addedColor.withAlpha(2)],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  FlTitlesData _titles(double interval) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
          interval: interval,
          getTitlesWidget: (value, meta) {
            if (value == meta.max) return const SizedBox();
            return SideTitleWidget(
              meta: meta,
              child: Text(
                value.round().toString(),
                style: graphAxisStyle(context),
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
                style: graphAxisStyle(context),
              ),
            );
          },
        ),
      ),
    );
  }

  BarTouchData _movementTouchData(AppLocalizations l10n) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => const Color(0xff202535),
        tooltipBorderRadius: BorderRadius.circular(12),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final label = rodIndex == 0 ? l10n.addedMilk : l10n.usedMilk;
          return BarTooltipItem(
            '${compactDate(_chartDays[group.x], context)}\n'
            '$label: ${rod.toY.round()} ml',
            TextStyle(
              color: rodIndex == 0 ? _addedColor : _usedColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          );
        },
      ),
    );
  }

  LineTouchData _stockTouchData(AppLocalizations l10n) {
    return LineTouchData(
      touchSpotThreshold: 24,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => const Color(0xff202535),
        tooltipBorderRadius: BorderRadius.circular(12),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (spots) => spots.map((spot) {
          final index = spot.x.round();
          return LineTooltipItem(
            '${compactDate(_chartDays[index], context)}\n'
            '${spot.y.round()} ml ${l10n.remaining.toLowerCase()}',
            const TextStyle(
              color: _addedColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _valuePill(String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

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
