import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:leyumi/features/diaper/diaper_entry.dart';
import 'package:leyumi/features/history/graphs/graph_style.dart';
import 'package:leyumi/services/diaper_storage.dart';

class DiaperGraphScreen extends StatefulWidget {
  const DiaperGraphScreen({super.key});

  @override
  State<DiaperGraphScreen> createState() => _DiaperGraphScreenState();
}

class _DiaperGraphScreenState extends State<DiaperGraphScreen> {
  static const _peeColor = Color(0xff56A8F5);
  static const _poopColor = Color(0xffD89A62);
  static const _bothColor = Color(0xffA878E8);

  List<DiaperEntry> entries = [];
  bool loading = true;
  String filter = '30';
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await DiaperStorage().loadEntries();
    data.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (!mounted) return;
    setState(() {
      entries = data;
      loading = false;
    });
  }

  List<DiaperEntry> get filtered {
    if (filter == 'all') return entries;
    final cutoff = DateTime.now().subtract(Duration(days: int.parse(filter)));
    return entries.where((entry) => entry.timestamp.isAfter(cutoff)).toList();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<DateTime> get sortedDays {
    final days = filtered
        .map((entry) => _dateOnly(entry.timestamp))
        .toSet()
        .toList();
    days.sort();
    return days;
  }

  Map<DateTime, List<DiaperEntry>> get entriesByDay {
    final result = <DateTime, List<DiaperEntry>>{};
    for (final entry in filtered) {
      result.putIfAbsent(_dateOnly(entry.timestamp), () => []).add(entry);
    }
    return result;
  }

  List<FlSpot> get dailySpots => List.generate(sortedDays.length, (index) {
    return FlSpot(
      index.toDouble(),
      (entriesByDay[sortedDays[index]]?.length ?? 0).toDouble(),
    );
  });

  int _typeCount(DiaperType type) =>
      filtered.where((entry) => entry.type == type).length;

  Map<int, int> get hourlyCounts {
    final result = <int, int>{for (var hour = 0; hour < 24; hour++) hour: 0};
    for (final entry in filtered) {
      result[entry.timestamp.hour] = result[entry.timestamp.hour]! + 1;
    }
    return result;
  }

  double get _dailyMax => chartMaximum(
    entriesByDay.values.map((dayEntries) => dayEntries.length.toDouble()),
    minimum: 4,
  );

  double get _hourlyMax => chartMaximum(
    hourlyCounts.values.map((value) => value.toDouble()),
    minimum: 2,
  );

  List<BarChartGroupData> get stackedBars {
    return List.generate(sortedDays.length, (index) {
      final dayEntries = entriesByDay[sortedDays[index]] ?? [];
      final pee = dayEntries
          .where((entry) => entry.type == DiaperType.pee)
          .length;
      final poop = dayEntries
          .where((entry) => entry.type == DiaperType.poop)
          .length;
      final both = dayEntries
          .where((entry) => entry.type == DiaperType.both)
          .length;
      final total = pee + poop + both;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total.toDouble(),
            width: math.max(
              7,
              math.min(16, 230 / math.max(sortedDays.length, 1)),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            rodStackItems: [
              BarChartRodStackItem(0, pee.toDouble(), _peeColor),
              BarChartRodStackItem(
                pee.toDouble(),
                (pee + poop).toDouble(),
                _poopColor,
              ),
              BarChartRodStackItem(
                (pee + poop).toDouble(),
                total.toDouble(),
                _bothColor,
              ),
            ],
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _dailyMax,
              color: Theme.of(context).dividerColor.withAlpha(22),
            ),
          ),
        ],
      );
    });
  }

  List<BarChartGroupData> get hourlyBars {
    return List.generate(24, (hour) {
      return BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: hourlyCounts[hour]!.toDouble(),
            width: 7,
            color: graphBlue,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _hourlyMax,
              color: Theme.of(context).dividerColor.withAlpha(22),
            ),
          ),
        ],
      );
    });
  }

  Map<PeeAmount, int> get peeAmountTotals {
    final totals = <PeeAmount, int>{
      PeeAmount.small: 0,
      PeeAmount.medium: 0,
      PeeAmount.large: 0,
    };
    for (final entry in filtered) {
      if (entry.peeAmount != null) {
        totals[entry.peeAmount!] = totals[entry.peeAmount!]! + 1;
      }
    }
    return totals;
  }

  String _percentage(PeeAmount amount) {
    final total = peeAmountTotals.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return '0%';
    return '${(peeAmountTotals[amount]! / total * 100).round()}%';
  }

  List<PieChartSectionData> get peeAmountSections {
    final totals = peeAmountTotals;
    final total = totals.values.fold(0, (sum, count) => sum + count);
    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Theme.of(context).dividerColor.withAlpha(70),
          showTitle: false,
          radius: 28,
        ),
      ];
    }

    const colors = [Color(0xff8DD7FF), graphBlue, Color(0xff3F4FA8)];
    return PeeAmount.values.map((amount) {
      final value = totals[amount]!.toDouble();
      return PieChartSectionData(
        value: value,
        color: colors[amount.index],
        showTitle: false,
        radius: 30,
      );
    }).toList();
  }

  FlTitlesData _dayTitles({required double interval}) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: interval,
          getTitlesWidget: (value, meta) {
            if (value == meta.max) return const SizedBox();
            return SideTitleWidget(
              meta: meta,
              child: Text(
                value.toInt().toString(),
                style: graphAxisStyle(context),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 34,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.round();
            if (value != index || index < 0 || index >= sortedDays.length) {
              return const SizedBox();
            }
            if (!shouldShowLabel(index, sortedDays.length)) {
              return const SizedBox();
            }
            return SideTitleWidget(
              meta: meta,
              space: 9,
              child: Text(
                compactDate(sortedDays[index], context),
                style: graphAxisStyle(context),
              ),
            );
          },
        ),
      ),
    );
  }

  LineTouchData _lineTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => const Color(0xff202535),
        tooltipBorderRadius: BorderRadius.circular(12),
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (spots) => spots.map((spot) {
          final index = spot.x.round();
          return LineTooltipItem(
            '${compactDate(sortedDays[index], context)}\n${spot.y.toInt()} changes',
            const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          );
        }).toList(),
      ),
    );
  }

  BarTouchData _barTouchData({required bool hourly}) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => const Color(0xff202535),
        tooltipBorderRadius: BorderRadius.circular(12),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final label = hourly
              ? '${group.x.toString().padLeft(2, '0')}:00'
              : compactDate(sortedDays[group.x], context);
          return BarTooltipItem(
            '$label\n${rod.toY.toInt()} changes',
            const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Diaper Analytics')),
      body: entries.isEmpty
          ? const Center(child: Text('No diaper data'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: GraphFilterBar(
                    value: filter,
                    options: const [
                      ('7d', '7'),
                      ('30d', '30'),
                      ('90d', '90'),
                      ('All', 'all'),
                    ],
                    onChanged: (value) => setState(() => filter = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _tabBar(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    child: filtered.isEmpty
                        ? _emptyRange()
                        : tabIndex == 0
                        ? _buildOverview()
                        : _buildInsights(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _tabBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.dividerColor.withAlpha(24),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [_tabButton('Overview', 0), _tabButton('Insights', 1)],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).cardColor : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? graphBlue
                  : Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withAlpha(160),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverview() {
    final interval = niceInterval(_dailyMax);
    return Column(
      children: [
        _summaryStrip(),
        PremiumChartCard(
          title: 'Daily changes',
          subtitle: 'Tap a point to see the exact day and total',
          trailing: _valuePill('${filtered.length} total', graphBlue),
          child: SizedBox(
            height: 230,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: math.max(0, sortedDays.length - 1).toDouble(),
                minY: 0,
                maxY: _dailyMax,
                gridData: premiumGrid(context, interval: interval),
                titlesData: _dayTitles(interval: interval),
                borderData: FlBorderData(show: false),
                lineTouchData: _lineTouchData(),
                lineBarsData: [
                  LineChartBarData(
                    spots: dailySpots,
                    isCurved: dailySpots.length > 2,
                    curveSmoothness: 0.22,
                    color: graphBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: dailySpots.length <= 10,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 3.5,
                          color: Theme.of(context).cardColor,
                          strokeWidth: 2.5,
                          strokeColor: graphBlue,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          graphBlue.withAlpha(65),
                          graphBlue.withAlpha(2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        PremiumChartCard(
          title: 'Daily composition',
          subtitle: 'Pee, poop and mixed changes by day',
          trailing: const GraphLegend(
            items: [
              (_peeColor, 'Pee'),
              (_poopColor, 'Poop'),
              (_bothColor, 'Both'),
            ],
            alignment: WrapAlignment.end,
          ),
          child: SizedBox(
            height: 235,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: _dailyMax,
                alignment: BarChartAlignment.spaceAround,
                gridData: premiumGrid(context, interval: interval),
                titlesData: _dayTitles(interval: interval),
                borderData: FlBorderData(show: false),
                barTouchData: _barTouchData(hourly: false),
                barGroups: stackedBars,
              ),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsights() {
    final totalPeeAmounts = peeAmountTotals.values.fold(
      0,
      (sum, value) => sum + value,
    );
    final interval = niceInterval(_hourlyMax);
    return Column(
      children: [
        PremiumChartCard(
          title: 'Pee amount distribution',
          subtitle: '$totalPeeAmounts changes include an amount',
          child: Row(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 48,
                        startDegreeOffset: -90,
                        sections: peeAmountSections,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalPeeAmounts',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'recorded',
                          style: graphAxisStyle(context, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _distributionRow(
                      const Color(0xff8DD7FF),
                      'Small',
                      _percentage(PeeAmount.small),
                    ),
                    _distributionRow(
                      graphBlue,
                      'Medium',
                      _percentage(PeeAmount.medium),
                    ),
                    _distributionRow(
                      const Color(0xff3F4FA8),
                      'Large',
                      _percentage(PeeAmount.large),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        PremiumChartCard(
          title: 'Activity by hour',
          subtitle: 'See when diaper changes happen most often',
          child: SizedBox(
            height: 235,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: _hourlyMax,
                alignment: BarChartAlignment.spaceAround,
                gridData: premiumGrid(context, interval: interval),
                borderData: FlBorderData(show: false),
                barTouchData: _barTouchData(hourly: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.max) return const SizedBox();
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toInt().toString(),
                            style: graphAxisStyle(context),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final hour = value.toInt();
                        if (hour < 0 || hour > 23 || hour % 4 != 0) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 9,
                          child: Text(
                            hour.toString().padLeft(2, '0'),
                            style: graphAxisStyle(context),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: hourlyBars,
              ),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryStrip() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(
            child: _summaryMetric(
              'Pee',
              _typeCount(DiaperType.pee),
              _peeColor,
              Icons.water_drop_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryMetric(
              'Poop',
              _typeCount(DiaperType.poop),
              _poopColor,
              Icons.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryMetric(
              'Both',
              _typeCount(DiaperType.both),
              _bothColor,
              Icons.blur_circular_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(45)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(label, style: graphAxisStyle(context, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _distributionRow(Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _valuePill(String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _emptyRange() {
    return PremiumChartCard(
      title: 'No data in this range',
      subtitle: 'Choose a wider time range to see your diaper trends.',
      child: const SizedBox(height: 80),
    );
  }
}
