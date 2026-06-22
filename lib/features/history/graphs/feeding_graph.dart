import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/features/history/graphs/graph_style.dart';
import 'package:leyumi/services/feeding_storage.dart';

class FeedingGraphScreen extends StatefulWidget {
  const FeedingGraphScreen({super.key});

  @override
  State<FeedingGraphScreen> createState() => _FeedingGraphScreenState();
}

class _FeedingGraphScreenState extends State<FeedingGraphScreen> {
  List<FeedingSession> sessions = [];
  bool loading = true;
  String filter = '30';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await FeedingStorage().loadSessions();
    data.sort((a, b) => a.startTime.compareTo(b.startTime));
    if (!mounted) return;
    setState(() {
      sessions = data;
      loading = false;
    });
  }

  List<FeedingSession> get filtered {
    if (filter == 'all') return sessions;
    final cutoff = DateTime.now().subtract(Duration(days: int.parse(filter)));
    return sessions
        .where((session) => session.startTime.isAfter(cutoff))
        .toList();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  List<DateTime> get sortedDays {
    final days = filtered
        .map((session) => _dateOnly(session.startTime))
        .toSet()
        .toList();
    days.sort();
    return days;
  }

  Map<DateTime, int> _dailySeconds(
    int Function(FeedingSession session) selector,
  ) {
    final result = <DateTime, int>{};
    for (final session in filtered) {
      final day = _dateOnly(session.startTime);
      result[day] = (result[day] ?? 0) + selector(session);
    }
    return result;
  }

  Map<DateTime, int> get dailyTotals =>
      _dailySeconds((session) => session.totalDuration.inSeconds);

  Map<DateTime, int> get leftTotals =>
      _dailySeconds((session) => session.leftDuration.inSeconds);

  Map<DateTime, int> get rightTotals =>
      _dailySeconds((session) => session.rightDuration.inSeconds);

  Map<DateTime, int> get milkTotals {
    final result = <DateTime, int>{};
    for (final session in filtered) {
      if (session.milkIntakeGr == null) continue;
      final day = _dateOnly(session.startTime);
      result[day] = (result[day] ?? 0) + session.milkIntakeGr!;
    }
    return result;
  }

  List<FlSpot> _spots(Map<DateTime, int> values, {bool seconds = true}) {
    return List.generate(sortedDays.length, (index) {
      final value = values[sortedDays[index]] ?? 0;
      return FlSpot(index.toDouble(), seconds ? value / 60 : value.toDouble());
    });
  }

  int _sum(Map<DateTime, int> values) =>
      values.values.fold(0, (sum, value) => sum + value);

  double _maxFor(List<Map<DateTime, int>> series, {required bool seconds}) {
    final values = <double>[];
    for (final map in series) {
      values.addAll(
        sortedDays.map((day) {
          final value = map[day] ?? 0;
          return seconds ? value / 60 : value.toDouble();
        }),
      );
    }
    return chartMaximum(values, minimum: seconds ? 10 : 50);
  }

  FlTitlesData _titles({
    required double interval,
    required String Function(double value) valueLabel,
  }) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 39,
          interval: interval,
          getTitlesWidget: (value, meta) {
            if (value == meta.max) return const SizedBox();
            return SideTitleWidget(
              meta: meta,
              child: Text(valueLabel(value), style: graphAxisStyle(context)),
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

  LineTouchData _touchData({
    required String unit,
    required List<String> labels,
  }) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => const Color(0xff202535),
        tooltipBorderRadius: BorderRadius.circular(12),
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (spots) {
          return spots.map((spot) {
            final index = spot.x.round();
            final prefix = labels.length > spot.barIndex
                ? '${labels[spot.barIndex]}: '
                : '';
            return LineTooltipItem(
              '${spot.barIndex == 0 ? '${compactDate(sortedDays[index], context)}\n' : ''}'
              '$prefix${spot.y.round()} $unit',
              TextStyle(
                color:
                    spot.bar.gradient?.colors.first ??
                    spot.bar.color ??
                    Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  LineChartBarData _line({
    required List<FlSpot> spots,
    required Color color,
    bool fill = false,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: spots.length > 2,
      curveSmoothness: 0.22,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: spots.length <= 10,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 3.5,
          color: Theme.of(context).cardColor,
          strokeWidth: 2.5,
          strokeColor: color,
        ),
      ),
      belowBarData: BarAreaData(
        show: fill,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withAlpha(55), color.withAlpha(2)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Feeding Analytics')),
      body: sessions.isEmpty
          ? const Center(child: Text('No feeding data'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    child: filtered.isEmpty
                        ? const PremiumChartCard(
                            title: 'No data in this range',
                            subtitle:
                                'Choose a wider time range to see feeding trends.',
                            child: SizedBox(height: 80),
                          )
                        : Column(
                            children: [
                              _summaryCard(),
                              _dailyTotalChart(),
                              _sideBalanceChart(),
                              _milkChart(),
                            ],
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryCard() {
    final totalMinutes = filtered.fold<int>(
      0,
      (sum, session) => sum + session.totalDuration.inMinutes,
    );
    final average = filtered.isEmpty
        ? 0
        : (totalMinutes / filtered.length).round();
    final totalMilk = _sum(milkTotals);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff4F7DFF), Color(0xff745EE8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: graphBlue.withAlpha(55),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL FEEDING TIME',
            style: TextStyle(
              color: Colors.white.withAlpha(180),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _durationLabel(totalMinutes),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _summaryValue('${filtered.length}', 'Sessions')),
              _summaryDivider(),
              Expanded(child: _summaryValue('$average min', 'Average')),
              _summaryDivider(),
              Expanded(child: _summaryValue('${totalMilk}g', 'Milk')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(175),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withAlpha(45),
    );
  }

  String _durationLabel(int minutes) {
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (hours == 0) return '$remaining min';
    if (remaining == 0) return '${hours}h';
    return '${hours}h ${remaining}m';
  }

  Widget _dailyTotalChart() {
    final maxY = _maxFor([dailyTotals], seconds: true);
    final interval = niceInterval(maxY);
    return PremiumChartCard(
      title: 'Daily feeding time',
      subtitle: 'Total active feeding minutes per day',
      trailing: _trendPill(_spots(dailyTotals)),
      child: SizedBox(
        height: 230,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: math.max(0, sortedDays.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            gridData: premiumGrid(context, interval: interval),
            borderData: FlBorderData(show: false),
            titlesData: _titles(
              interval: interval,
              valueLabel: (value) => '${value.round()}m',
            ),
            lineTouchData: _touchData(unit: 'min', labels: const ['Total']),
            lineBarsData: [
              _line(spots: _spots(dailyTotals), color: graphBlue, fill: true),
            ],
          ),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  Widget _sideBalanceChart() {
    final maxY = _maxFor([leftTotals, rightTotals], seconds: true);
    final interval = niceInterval(maxY);
    return PremiumChartCard(
      title: 'Left & right balance',
      subtitle: 'Daily feeding duration on each side',
      trailing: const GraphLegend(
        items: [(graphPink, 'Left'), (graphBlue, 'Right')],
        alignment: WrapAlignment.end,
      ),
      child: SizedBox(
        height: 230,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: math.max(0, sortedDays.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            gridData: premiumGrid(context, interval: interval),
            borderData: FlBorderData(show: false),
            titlesData: _titles(
              interval: interval,
              valueLabel: (value) => '${value.round()}m',
            ),
            lineTouchData: _touchData(
              unit: 'min',
              labels: const ['Left', 'Right'],
            ),
            lineBarsData: [
              _line(spots: _spots(leftTotals), color: graphPink),
              _line(spots: _spots(rightTotals), color: graphBlue),
            ],
          ),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  Widget _milkChart() {
    final maxY = _maxFor([milkTotals], seconds: false);
    final interval = niceInterval(maxY);
    final hasMilk = milkTotals.values.any((value) => value > 0);

    return PremiumChartCard(
      title: 'Milk intake',
      subtitle: 'Recorded intake from weight-based sessions',
      trailing: _valuePill('${_sum(milkTotals)}g total', graphGreen),
      child: hasMilk
          ? SizedBox(
              height: 230,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: math.max(0, sortedDays.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  gridData: premiumGrid(context, interval: interval),
                  borderData: FlBorderData(show: false),
                  titlesData: _titles(
                    interval: interval,
                    valueLabel: (value) => '${value.round()}g',
                  ),
                  lineTouchData: _touchData(unit: 'g', labels: const ['Milk']),
                  lineBarsData: [
                    _line(
                      spots: _spots(milkTotals, seconds: false),
                      color: graphGreen,
                      fill: true,
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              ),
            )
          : SizedBox(
              height: 110,
              child: Center(
                child: Text(
                  'No milk intake has been recorded for this period.',
                  textAlign: TextAlign.center,
                  style: graphAxisStyle(context, fontSize: 12),
                ),
              ),
            ),
    );
  }

  Widget _trendPill(List<FlSpot> spots) {
    if (spots.length < 2) return const SizedBox();
    final change = spots.last.y - spots[spots.length - 2].y;
    final color = change >= 0 ? graphGreen : graphPink;
    final icon = change >= 0
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 3),
          Text(
            '${change.abs().round()}m',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
