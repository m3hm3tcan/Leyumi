import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:babyfeedpro/features/feeding/feeding_session.dart';
import 'package:babyfeedpro/services/feeding_storage.dart';

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
    setState(() => sessions = data);
  }

  List<FeedingSession> get filtered {
    if (filter == "all") return sessions;
    final days = int.parse(filter);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return sessions.where((s) => s.startTime.isAfter(cutoff)).toList();
  }

  // -------------------------------------------------------
  // AGGREGATED MAPS
  // -------------------------------------------------------

  String _dayKey(DateTime d) => "${d.year}-${d.month}-${d.day}";

  List<String> get sortedDays {
    final keys = filtered.map((s) => _dayKey(s.startTime)).toSet().toList();
    keys.sort();
    return keys;
  }

  int _sum(Map<String, int> map) => map.values.fold(0, (a, b) => a + b);

  Map<String, int> get dailyTotals {
    final map = <String, int>{};
    for (var s in filtered) {
      final key = _dayKey(s.startTime);
      map[key] = (map[key] ?? 0) + s.totalDuration.inSeconds;
    }
    return map;
  }

  Map<String, int> get leftTotals {
    final map = <String, int>{};
    for (var s in filtered) {
      final key = _dayKey(s.startTime);
      map[key] = (map[key] ?? 0) + s.leftDuration.inSeconds;
    }
    return map;
  }

  Map<String, int> get rightTotals {
    final map = <String, int>{};
    for (var s in filtered) {
      final key = _dayKey(s.startTime);
      map[key] = (map[key] ?? 0) + s.rightDuration.inSeconds;
    }
    return map;
  }

  Map<String, int> get milkTotals {
    final map = <String, int>{};
    for (var s in filtered) {
      if (s.milkIntakeGr != null) {
        final key = _dayKey(s.startTime);
        map[key] = (map[key] ?? 0) + s.milkIntakeGr!;
      }
    }
    return map;
  }

  // -------------------------------------------------------
  // SPOTS
  // -------------------------------------------------------

  List<FlSpot> _spots(Map<String, int> map, {bool minutes = true}) {
    return List.generate(sortedDays.length, (i) {
      final key = sortedDays[i];
      final value = map[key] ?? 0;
      return FlSpot(i.toDouble(), minutes ? value / 60 : value.toDouble());
    });
  }

  // -------------------------------------------------------
  // UI HELPERS
  // -------------------------------------------------------

  String _formatDay(String key) {
    final p = key.split("-");
    final d = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    return DateFormat("dd MMM").format(d); // 05 Jun
  }

  Widget _filterButton(String label, String value) {
    final selected = filter == value;
    return GestureDetector(
      onTap: () => setState(() => filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.blue : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.blue : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _chartCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 14),
          chart,
        ],
      ),
    );
  }

  Widget _summaryCard() {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Summary", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 12),
          Text("$totalMin min", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // BUILD
  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text("Feeding Charts"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: sessions.isEmpty
          ? const Center(child: Text("No feeding data"))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _filterButton("7d", "7"),
                      _filterButton("30d", "30"),
                      _filterButton("90d", "90"),
                      _filterButton("All", "all"),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _summaryCard(),

                        // DAILY TOTAL
                        _chartCard(
                          "Daily Total Feeding",
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                minY: 0,
                                gridData: FlGridData(show: true, drawVerticalLine: false),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          "${value.toInt()} min",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                                        if (i < 0 || i >= sortedDays.length) return const SizedBox();
                                        return Text(_formatDay(sortedDays[i]), style: const TextStyle(fontSize: 11));
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

                        // LEFT / RIGHT SCATTER
                        _chartCard(
                          "Left / Right Feeding",
                          SizedBox(
                            height: 200,
                            child: ScatterChart(
                              ScatterChartData(
                                minY: 0,
                                gridData: FlGridData(show: true),
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
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                                        if (i < 0 || i >= sortedDays.length) return const SizedBox();
                                        return Text(
                                          _formatDay(sortedDays[i]),
                                          style: const TextStyle(fontSize: 11),
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
                                      dotPainter: FlDotCirclePainter(color: Colors.pinkAccent, radius: 6),
                                    ),
                                  ),
                                  ..._spots(rightTotals).map(
                                    (e) => ScatterSpot(
                                      e.x,
                                      e.y,
                                      dotPainter: FlDotCirclePainter(color: Colors.blueAccent, radius: 6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // MILK TREND
                        _chartCard(
                          "Milk Intake (g)",
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                minY: 0,
                                gridData: FlGridData(show: true),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (value, meta) {
                                        final i = value.toInt();
                                        if (i < 0 || i >= sortedDays.length) return const SizedBox();
                                        return Text(_formatDay(sortedDays[i]), style: const TextStyle(fontSize: 11));
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
