import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/services/feeding_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedingGraphScreen extends StatefulWidget {
  const FeedingGraphScreen({super.key});

  @override
  State<FeedingGraphScreen> createState() => _FeedingGraphScreenState();
}

class _FeedingGraphScreenState extends State<FeedingGraphScreen> {
  List<FeedingSession> sessions = [];
  String filter = "30";

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await FeedingStorage().loadSessions();
    data.sort((a, b) => a.startTime.compareTo(b.startTime));
    if (!mounted) return;
    setState(() => sessions = data);
  }

  List<FeedingSession> get filtered {
    if (filter == "all") return sessions;
    final days = int.parse(filter);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return sessions.where((s) => s.startTime.isAfter(cutoff)).toList();
  }

  String _dayKey(DateTime d) => "${d.year}-${d.month}-${d.day}";

  List<String> get sortedDays {
    final keys = filtered.map((s) => _dayKey(s.startTime)).toSet().toList();
    keys.sort();
    return keys;
  }

  int _sum(Map<String, int> map) => map.values.fold(0, (a, b) => a + b);

  Map<String, int> get dailyTotals {
    final map = <String, int>{};
    for (final s in filtered) {
      final key = _dayKey(s.startTime);
      map[key] = (map[key] ?? 0) + s.totalDuration.inSeconds;
    }
    return map;
  }

  Map<String, int> get leftTotals {
    final map = <String, int>{};
    for (final s in filtered) {
      final key = _dayKey(s.startTime);
      map[key] = (map[key] ?? 0) + s.leftDuration.inSeconds;
    }
    return map;
  }

  Map<String, int> get rightTotals {
    final map = <String, int>{};
    for (final s in filtered) {
      final key = _dayKey(s.startTime);
      map[key] = (map[key] ?? 0) + s.rightDuration.inSeconds;
    }
    return map;
  }

  Map<String, int> get milkTotals {
    final map = <String, int>{};
    for (final s in filtered) {
      if (s.milkIntakeGr != null) {
        final key = _dayKey(s.startTime);
        map[key] = (map[key] ?? 0) + s.milkIntakeGr!;
      }
    }
    return map;
  }

  List<FlSpot> _spots(Map<String, int> map, {bool minutes = true}) {
    return List.generate(sortedDays.length, (i) {
      final key = sortedDays[i];
      final value = map[key] ?? 0;
      return FlSpot(i.toDouble(), minutes ? value / 60 : value.toDouble());
    });
  }

  String _formatDay(String key) {
    final p = key.split("-");
    final d = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    return DateFormat("dd MMM").format(d);
  }

  Widget _filterButton(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final selected = filter == value;
    final unselectedBorder =
        theme.dividerColor.withAlpha(theme.brightness == Brightness.dark ? 90 : 160);

    return GestureDetector(
      onTap: () => setState(() => filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.blue.withAlpha(theme.brightness == Brightness.dark ? 35 : 20)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.blue : unselectedBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected
                ? Colors.blue
                : (theme.textTheme.bodyMedium?.color ?? Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _chartCard(BuildContext context, String title, Widget chart) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 35 : 10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 14),
          chart,
        ],
      ),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;
    final totalMin = filtered.fold<int>(0, (a, b) => a + b.totalDuration.inMinutes);
    final left = _sum(leftTotals);
    final right = _sum(rightTotals);
    final milk = _sum(milkTotals);

    final total = left + right;
    final leftPct = total == 0 ? 0 : (left / total * 100).round();
    final rightPct = total == 0 ? 0 : (right / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 35 : 10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Summary",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$totalMin min",
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _metric("Left", "$leftPct%", Colors.pinkAccent)),
              const SizedBox(width: 10),
              Expanded(child: _metric("Right", "$rightPct%", Colors.blueAccent)),
              const SizedBox(width: 10),
              Expanded(child: _metric("Milk", "${milk}g", Colors.green)),
            ],
          )
        ],
      ),
    );
  }

  Widget _metric(String title, String value, Color color) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(theme.brightness == Brightness.dark ? 30 : 20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        );
      },
    );
  }

  TextStyle _axisTextStyle(BuildContext context, {double size = 11}) {
    final color =
        Theme.of(context).textTheme.bodySmall?.color?.withAlpha(170) ?? Colors.grey;
    return TextStyle(fontSize: size, color: color, fontWeight: FontWeight.w600);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final axisColor =
        theme.textTheme.bodySmall?.color?.withAlpha(170) ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feeding Charts"),
        elevation: 0,
      ),
      body: sessions.isEmpty
          ? Center(
              child: Text(
                "No feeding data",
                style: TextStyle(color: axisColor),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _filterButton(context, "7d", "7"),
                      _filterButton(context, "30d", "30"),
                      _filterButton(context, "90d", "90"),
                      _filterButton(context, "All", "all"),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _summaryCard(context),
                        _chartCard(
                          context,
                          "Daily Total Feeding",
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                minY: 0,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (_) => FlLine(
                                    color: axisColor.withAlpha(60),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          "${value.toInt()} min",
                                          style: _axisTextStyle(context),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (value, meta) {
                                        final i = value.toInt();
                                        if (i < 0 || i >= sortedDays.length) {
                                          return const SizedBox();
                                        }
                                        return Text(
                                          _formatDay(sortedDays[i]),
                                          style: _axisTextStyle(context, size: 11),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _spots(dailyTotals),
                                    isCurved: true,
                                    color: Colors.blueAccent,
                                    barWidth: 3,
                                    dotData: FlDotData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _chartCard(
                          context,
                          "Left / Right Feeding",
                          SizedBox(
                            height: 200,
                            child: ScatterChart(
                              ScatterChartData(
                                minY: 0,
                                gridData: FlGridData(
                                  show: true,
                                  getDrawingHorizontalLine: (_) => FlLine(
                                    color: axisColor.withAlpha(60),
                                    strokeWidth: 1,
                                  ),
                                  getDrawingVerticalLine: (_) => FlLine(
                                    color: axisColor.withAlpha(40),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 5,
                                      reservedSize: 38,
                                      getTitlesWidget: (value, meta) {
                                        if (value % 5 != 0) return const SizedBox();
                                        return Text(
                                          "${value.toInt()} min",
                                          style: _axisTextStyle(context, size: 10),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (value, meta) {
                                        final i = value.toInt();
                                        if (i < 0 || i >= sortedDays.length) {
                                          return const SizedBox();
                                        }
                                        return Text(
                                          _formatDay(sortedDays[i]),
                                          style: _axisTextStyle(context, size: 11),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                scatterSpots: [
                                  ..._spots(leftTotals).map(
                                    (e) => ScatterSpot(
                                      e.x,
                                      e.y,
                                      dotPainter: FlDotCirclePainter(
                                        color: Colors.pinkAccent,
                                        radius: 6,
                                      ),
                                    ),
                                  ),
                                  ..._spots(rightTotals).map(
                                    (e) => ScatterSpot(
                                      e.x,
                                      e.y,
                                      dotPainter: FlDotCirclePainter(
                                        color: Colors.blueAccent,
                                        radius: 6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _chartCard(
                          context,
                          "Milk Intake (g)",
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                minY: 0,
                                gridData: FlGridData(
                                  show: true,
                                  getDrawingHorizontalLine: (_) => FlLine(
                                    color: axisColor.withAlpha(60),
                                    strokeWidth: 1,
                                  ),
                                  getDrawingVerticalLine: (_) => FlLine(
                                    color: axisColor.withAlpha(40),
                                    strokeWidth: 1,
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 36,
                                      getTitlesWidget: (value, meta) =>
                                          Text(value.toInt().toString(),
                                              style: _axisTextStyle(context)),
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (value, meta) {
                                        final i = value.toInt();
                                        if (i < 0 || i >= sortedDays.length) {
                                          return const SizedBox();
                                        }
                                        return Text(
                                          _formatDay(sortedDays[i]),
                                          style: _axisTextStyle(context, size: 11),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _spots(milkTotals, minutes: false),
                                    isCurved: true,
                                    color: Colors.green,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
