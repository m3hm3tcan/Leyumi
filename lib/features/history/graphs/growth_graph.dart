import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:babyfeedpro/models/growth_entry.dart';
import 'package:babyfeedpro/services/growth_storage.dart';
import 'package:babyfeedpro/l10n/app_localizations.dart';

class GrowthGraphScreen extends StatefulWidget {
  const GrowthGraphScreen({super.key});

  @override
  State<GrowthGraphScreen> createState() => _GrowthGraphScreenState();
}

class _GrowthGraphScreenState extends State<GrowthGraphScreen> {
  List<GrowthEntry> entries = [];
  String filter = "30"; // default 30 gün

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await GrowthStorage().loadEntries();
    data.sort((a, b) => a.date.compareTo(b.date)); // grafik için eski → yeni
    setState(() => entries = data);
  }

  List<GrowthEntry> get filtered {
    if (filter == "all") return entries;

    final days = int.parse(filter);
    final cutoff = DateTime.now().subtract(Duration(days: days));

    return entries.where((e) => e.date.isAfter(cutoff)).toList();
  }

  List<FlSpot> _spotsWeight() {
    final list = filtered.toList();
    return list.asMap().entries.map(
      (e) => FlSpot(
        e.key.toDouble(),
        e.value.weight.toDouble(),
      ),
    ).toList();
  }



  List<FlSpot> _spotsHeight() {
    final list = filtered.toList();
    return list
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.height.toDouble()))
        .toList();
  }

  List<FlSpot> _spotsHead() {
    final list = filtered.where((e) => e.headCircumference != null).toList();
    return list.asMap().entries.map(
      (e) => FlSpot(
        e.key.toDouble(),
        e.value.headCircumference!.toDouble(),
      ),
    ).toList();
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
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
          ),
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

  Widget _chartCard(String title, List<FlSpot> spots, Color color) {
    final l10n = AppLocalizations.of(context);
    if (spots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text("${title}: ${l10n.noData}"),
      );
    }

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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) * 0.95,
                maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.05,
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= filtered.length) return const SizedBox();

                        final date = filtered[index].date;
                        final label = l10n.dateFormat
                            .replaceFirst("{day}", date.day.toString())
                            .replaceFirst("{month}", date.month.toString());


                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: Text(l10n.growthCharts),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: entries.isEmpty
          ? Center(child: Text(l10n.noGrowthData))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// FILTERS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _filterButton(l10n.filter7d, "7"),
                      _filterButton(l10n.filter30d, "30"),
                      _filterButton(l10n.filter90d, "90"),
                      _filterButton(l10n.filterAll, "all"),

                    ],
                  ),

                  const SizedBox(height: 20),

                  /// WEIGHT
                  _chartCard(
                    l10n.weight,
                    _spotsWeight(),
                    Colors.blueAccent,
                  ),

                  /// HEIGHT
                  _chartCard(
                    l10n.height,
                    _spotsHeight(),
                    Colors.green,
                  ),

                  /// HEAD CIRCUMFERENCE
                  _chartCard(
                    l10n.headCircumference,
                    _spotsHead(),
                    Colors.purple,
                  ),
                ],
              ),
            ),
    );
  }
}
