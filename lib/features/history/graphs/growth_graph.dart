import 'package:leyumi/core/premium/premium_feature.dart';
import 'package:leyumi/core/premium/premium_provider.dart';
import 'package:leyumi/features/premium/premium_paywall_screen.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:leyumi/models/growth_entry.dart';
import 'package:leyumi/services/growth_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GrowthGraphScreen extends StatefulWidget {
  const GrowthGraphScreen({super.key});

  @override
  State<GrowthGraphScreen> createState() => _GrowthGraphScreenState();
}

class _GrowthGraphScreenState extends State<GrowthGraphScreen> {
  List<GrowthEntry> entries = [];
  String filter = "30";

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await GrowthStorage().loadEntries();
    data.sort((a, b) => a.date.compareTo(b.date));
    if (!mounted) return;
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
    return list.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight.toDouble());
    }).toList();
  }

  List<FlSpot> _spotsHeight() {
    final list = filtered.toList();
    return list.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.height.toDouble());
    }).toList();
  }

  List<FlSpot> _spotsHead() {
    final list = filtered.where((e) => e.headCircumference != null).toList();
    return list.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.headCircumference!.toDouble());
    }).toList();
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

  TextStyle _axisTextStyle(BuildContext context) {
    final color =
        Theme.of(context).textTheme.bodySmall?.color?.withAlpha(170) ?? Colors.grey;
    return TextStyle(fontSize: 10, color: color);
  }

  Widget _chartCard(
    BuildContext context,
    String title,
    List<FlSpot> spots,
    Color color,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final axisColor =
        theme.textTheme.bodySmall?.color?.withAlpha(170) ?? Colors.grey;

    if (spots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text("$title: ${l10n.noData}"),
      );
    }

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
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: _axisTextStyle(context),
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
                        if (index < 0 || index >= filtered.length) {
                          return const SizedBox();
                        }

                        final date = filtered[index].date;
                        final label = l10n.dateFormat
                            .replaceFirst("{day}", date.day.toString())
                            .replaceFirst("{month}", date.month.toString());

                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: _axisTextStyle(context),
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
    final premium = context.watch<PremiumProvider>();

    if (!premium.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!premium.hasAccess(PremiumFeature.advancedAnalytics)) {
      return const PremiumPaywallScreen(
        feature: PremiumFeature.advancedAnalytics,
      );
    }

    final theme = Theme.of(context);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.growthCharts),
        elevation: 0,
      ),
      body: entries.isEmpty
          ? Center(child: Text(l10n.noGrowthData, style: TextStyle(color: secondaryTextColor)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _filterButton(context, l10n.filter7d, "7"),
                      _filterButton(context, l10n.filter30d, "30"),
                      _filterButton(context, l10n.filter90d, "90"),
                      _filterButton(context, l10n.filterAll, "all"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _chartCard(context, l10n.weight, _spotsWeight(), Colors.blueAccent),
                  _chartCard(context, l10n.height, _spotsHeight(), Colors.green),
                  _chartCard(context, l10n.headCircumference, _spotsHead(), Colors.purple),
                ],
              ),
            ),
    );
  }
}
