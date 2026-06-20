import 'package:babyfeedpro/features/diaper/diaper_entry.dart';
import 'package:babyfeedpro/services/diaper_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DiaperGraphScreen extends StatefulWidget {
  const DiaperGraphScreen({super.key});

  @override
  State<DiaperGraphScreen> createState() => _DiaperGraphScreenState();
}

class _DiaperGraphScreenState extends State<DiaperGraphScreen> {
  List<DiaperEntry> entries = [];
  bool loading = true;
  String filter = "30";
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

  Map<String, int> get dailyTotals {
    final map = <String, int>{};
    for (final e in filtered) {
      final key = "${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}";
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  List<DiaperEntry> get filtered {
    if (filter == "all") return entries;
    final days = int.parse(filter);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return entries.where((e) => e.timestamp.isAfter(cutoff)).toList();
  }

  List<String> get sortedDays {
    final keys = dailyTotals.keys.toList();
    keys.sort((a, b) {
      final pa = a.split("-");
      final pb = b.split("-");
      final da = DateTime(int.parse(pa[0]), int.parse(pa[1]), int.parse(pa[2]));
      final db = DateTime(int.parse(pb[0]), int.parse(pb[1]), int.parse(pb[2]));
      return da.compareTo(db);
    });
    return keys;
  }

  List<FlSpot> get dailySpots {
    final days = sortedDays;
    return List.generate(days.length, (i) {
      final count = dailyTotals[days[i]] ?? 0;
      return FlSpot(i.toDouble(), count.toDouble());
    });
  }

  Map<int, int> get hourlyCounts {
    final map = <int, int>{};
    for (int i = 0; i < 24; i++) {
      map[i] = 0;
    }
    for (final e in filtered) {
      final hour = e.timestamp.hour;
      map[hour] = map[hour]! + 1;
    }
    return map;
  }

  List<BarChartGroupData> get hourlyBars {
    return List.generate(24, (i) {
      final count = hourlyCounts[i]!.toDouble();
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: count,
            color: Colors.blueAccent,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  TextStyle _axisTextStyle(BuildContext context, {double size = 12}) {
    final color =
        Theme.of(context).textTheme.bodySmall?.color?.withAlpha(170) ?? Colors.grey;
    return TextStyle(fontSize: size, color: color, fontWeight: FontWeight.w600);
  }

  FlTitlesData buildHourTitles(BuildContext context) {
    return FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
          getTitlesWidget: (value, meta) {
            return Text("${value.toInt()}x", style: _axisTextStyle(context));
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          getTitlesWidget: (value, meta) {
            final hour = value.toInt();
            if (hour < 0 || hour > 23) return const SizedBox();
            return Text("$hour", style: _axisTextStyle(context, size: 11));
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> get stackedBars {
    final days = sortedDays;
    return List.generate(days.length, (i) {
      final key = days[i];
      final pee = (dailyPee[key] ?? 0).toDouble();
      final poop = (dailyPoop[key] ?? 0).toDouble();
      final both = (dailyBoth[key] ?? 0).toDouble();

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: pee + poop + both,
            rodStackItems: [
              BarChartRodStackItem(0, pee, Colors.blueAccent),
              BarChartRodStackItem(pee, pee + poop, Colors.brown.shade400),
              BarChartRodStackItem(
                pee + poop,
                pee + poop + both,
                Colors.purpleAccent,
              ),
            ],
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  FlGridData appleGrid(BuildContext context) {
    final color =
        Theme.of(context).textTheme.bodySmall?.color?.withAlpha(60) ?? Colors.grey;
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 1,
      getDrawingHorizontalLine: (value) => FlLine(
        color: color,
        strokeWidth: 1,
      ),
    );
  }

  Map<String, int> get dailyPee {
    final map = <String, int>{};
    for (final e in filtered) {
      if (e.type == DiaperType.pee) {
        final key = "${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}";
        map[key] = (map[key] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<String, int> get dailyPoop {
    final map = <String, int>{};
    for (final e in filtered) {
      if (e.type == DiaperType.poop) {
        final key = "${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}";
        map[key] = (map[key] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<String, int> get dailyBoth {
    final map = <String, int>{};
    for (final e in filtered) {
      if (e.type == DiaperType.both) {
        final key = "${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}";
        map[key] = (map[key] ?? 0) + 1;
      }
    }
    return map;
  }

  Map<PeeAmount, int> get peeAmountTotals {
    final map = <PeeAmount, int>{
      PeeAmount.small: 0,
      PeeAmount.medium: 0,
      PeeAmount.large: 0,
    };

    for (final e in filtered) {
      if (e.peeAmount != null) {
        map[e.peeAmount!] = map[e.peeAmount!]! + 1;
      }
    }
    return map;
  }

  List<PieChartSectionData> get peeAmountSections {
    final totals = peeAmountTotals;
    final total = totals.values.fold(0, (a, b) => a + b);

    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey.shade300,
          title: "No Data",
          radius: 60,
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: totals[PeeAmount.small]!.toDouble(),
        color: Colors.lightBlueAccent,
        title: "${(totals[PeeAmount.small]! / total * 100).toStringAsFixed(0)}%",
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: totals[PeeAmount.medium]!.toDouble(),
        color: Colors.blueAccent,
        title: "${(totals[PeeAmount.medium]! / total * 100).toStringAsFixed(0)}%",
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: totals[PeeAmount.large]!.toDouble(),
        color: Colors.indigo,
        title: "${(totals[PeeAmount.large]! / total * 100).toStringAsFixed(0)}%",
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ];
  }

  Map<String, String> get peeAmountPercentages {
    final totals = peeAmountTotals;
    final total = totals.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return {"small": "0%", "medium": "0%", "large": "0%"};
    }
    return {
      "small": "${(totals[PeeAmount.small]! / total * 100).toStringAsFixed(0)}%",
      "medium": "${(totals[PeeAmount.medium]! / total * 100).toStringAsFixed(0)}%",
      "large": "${(totals[PeeAmount.large]! / total * 100).toStringAsFixed(0)}%",
    };
  }

  FlTitlesData buildTitles(BuildContext context) {
    return FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
          getTitlesWidget: (value, meta) {
            return Text("${value.toInt()}x", style: _axisTextStyle(context));
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            if (value % 1 != 0) return const SizedBox();
            final i = value.toInt();
            if (i < 0 || i >= sortedDays.length) return const SizedBox();
            final d = sortedDays[i].split("-");
            return Text(
              "${d[2]}/${d[1]}",
              style: _axisTextStyle(context),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Diaper Analytics")),
        body: Center(
          child: Text("No diaper data", style: TextStyle(color: secondaryTextColor)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Diaper Analytics"),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilters(context),
          const SizedBox(height: 12),
          _buildTabs(context),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: tabIndex == 0 ? _buildOverview(context) : _buildInsights(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(BuildContext context) {
    return Column(
      children: [
        _chartCard(
          context,
          "Daily Changes (Total Diapers)",
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: appleGrid(context),
                titlesData: buildTitles(context),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: dailySpots,
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ),
        _chartCard(
          context,
          "Pee / Poop / Both (Stacked)",
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                gridData: appleGrid(context),
                borderData: FlBorderData(show: false),
                titlesData: buildTitles(context),
                barGroups: stackedBars,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsights(BuildContext context) {
    return Column(
      children: [
        _chartCard(
          context,
          "Pee Amount Distribution",
          Column(
            children: [
              SizedBox(
                height: 240,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: peeAmountSections,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _legendItem(Colors.lightBlueAccent, "Small", peeAmountPercentages["small"]!),
              const SizedBox(height: 6),
              _legendItem(Colors.blueAccent, "Medium", peeAmountPercentages["medium"]!),
              const SizedBox(height: 6),
              _legendItem(Colors.indigo, "Large", peeAmountPercentages["large"]!),
            ],
          ),
        ),
        _chartCard(
          context,
          "Hourly Activity Histogram",
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                gridData: appleGrid(context),
                borderData: FlBorderData(show: false),
                titlesData: buildHourTitles(context),
                barGroups: hourlyBars,
              ),
            ),
          ),
        ),
      ],
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

  Widget _legendItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          "$label: $value",
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _filterButton(context, "7d", "7"),
          _filterButton(context, "30d", "30"),
          _filterButton(context, "90d", "90"),
          _filterButton(context, "All", "all"),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tabButton(context, "Overview", 0),
          const SizedBox(width: 10),
          _tabButton(context, "Insights", 1),
        ],
      ),
    );
  }

  Widget _filterButton(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final selected = filter == value;
    final unselectedBorder =
        theme.dividerColor.withAlpha(theme.brightness == Brightness.dark ? 90 : 160);

    return GestureDetector(
      onTap: () {
        setState(() {
          filter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.blue.withAlpha(theme.brightness == Brightness.dark ? 35 : 20)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.blue : unselectedBorder,
          ),
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

  Widget _tabButton(BuildContext context, String label, int index) {
    final theme = Theme.of(context);
    final selected = tabIndex == index;
    final unselectedBorder =
        theme.dividerColor.withAlpha(theme.brightness == Brightness.dark ? 90 : 160);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            tabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? Colors.blue.withAlpha(theme.brightness == Brightness.dark ? 35 : 20)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? Colors.blue : unselectedBorder,
            ),
          ),
          child: Center(
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
        ),
      ),
    );
  }
}
