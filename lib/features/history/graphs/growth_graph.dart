import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/child/active_child_aware.dart';
import '../../../core/child/active_child_provider.dart';
import '../../../core/premium/premium_feature.dart';
import '../../../core/premium/premium_provider.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/baby_profile.dart';
import '../../../models/growth_entry.dart';
import '../../../services/growth_storage.dart';
import '../../premium/premium_paywall_screen.dart';
import 'graph_style.dart';

class GrowthGraphScreen extends StatefulWidget {
  const GrowthGraphScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<GrowthGraphScreen> createState() => _GrowthGraphScreenState();
}

class _GrowthGraphScreenState extends State<GrowthGraphScreen>
    with ActiveChildAware<GrowthGraphScreen> {
  static const _weightColor = Color(0xff4F7DFF);
  static const _heightColor = Color(0xff21B981);
  static const _headColor = Color(0xff9B6BE8);

  List<GrowthEntry> entries = [];
  bool loading = true;
  String filter = 'all';

  BabyProfile? get profile => context.read<ActiveChildProvider>().activeChild;

  Future<void> load() async {
    final data = await GrowthStorage().loadEntries();
    data.sort((a, b) => a.date.compareTo(b.date));
    if (!mounted) return;
    setState(() {
      entries = data;
      loading = false;
    });
  }

  @override
  Future<void> onActiveChildChanged() => load();

  List<GrowthEntry> get filtered {
    if (filter == 'all') return entries;
    final cutoff = AppDateUtils.startOfRange(int.parse(filter));
    return entries.where((entry) => !entry.date.isBefore(cutoff)).toList();
  }

  double _ageInDays(DateTime date) {
    final birthDate = profile?.birthDate;
    if (birthDate == null) return 0;
    final age = AppDateUtils.dateOnly(
      date,
    ).difference(AppDateUtils.dateOnly(birthDate)).inDays;
    return math.max(0, age).toDouble();
  }

  List<_GrowthPoint> _points(double? Function(GrowthEntry entry) valueOf) {
    return filtered
        .map((entry) {
          final value = valueOf(entry);
          return value == null
              ? null
              : _GrowthPoint(entry, _ageInDays(entry.date), value);
        })
        .whereType<_GrowthPoint>()
        .toList();
  }

  String _formatAge(double value, AppLocalizations l10n) {
    final days = math.max(0, value.round());
    if (days < 60) return '$days${l10n.daysShort}';
    final months = (days / 30.4375).round();
    if (months < 24) return '$months${l10n.monthsShort}';
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    return remainingMonths == 0
        ? '$years${l10n.yearsShort}'
        : '$years${l10n.yearsShort} $remainingMonths${l10n.monthsShort}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final premium = context.watch<PremiumProvider>();

    if (!premium.isLoaded || loading) {
      const loadingView = Center(child: CircularProgressIndicator());
      return widget.embedded ? loadingView : const Scaffold(body: loadingView);
    }
    if (!premium.hasAccess(PremiumFeature.advancedAnalytics)) {
      return const PremiumPaywallScreen(
        feature: PremiumFeature.advancedAnalytics,
      );
    }

    final body = entries.isEmpty
        ? Center(child: Text(l10n.noGrowthData))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: GraphFilterBar(
                  value: filter,
                  accent: _heightColor,
                  options: [
                    (l10n.filter7d, '7'),
                    (l10n.filter30d, '30'),
                    (l10n.filter90d, '90'),
                    (l10n.filterAll, 'all'),
                  ],
                  onChanged: (value) => setState(() => filter = value),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  child: filtered.isEmpty
                      ? PremiumChartCard(
                          title: l10n.noDataInRange,
                          child: const SizedBox(height: 80),
                        )
                      : Column(
                          children: [
                            _summaryCard(l10n),
                            _metricChart(
                              title: l10n.weight,
                              icon: Icons.monitor_weight_rounded,
                              color: _weightColor,
                              points: _points((entry) => entry.weight / 1000),
                              unit: l10n.unitKg,
                              decimals: 2,
                              minimumPadding: .25,
                            ),
                            _metricChart(
                              title: l10n.height,
                              icon: Icons.height_rounded,
                              color: _heightColor,
                              points: _points(
                                (entry) => entry.height.toDouble(),
                              ),
                              unit: l10n.unitCm,
                              decimals: 0,
                              minimumPadding: 2,
                            ),
                            _metricChart(
                              title: l10n.headCircumference,
                              icon: Icons.face_retouching_natural_rounded,
                              color: _headColor,
                              points: _points(
                                (entry) => entry.headCircumference?.toDouble(),
                              ),
                              unit: l10n.unitCm,
                              decimals: 0,
                              minimumPadding: 1,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.growthCharts)),
      body: body,
    );
  }

  Widget _summaryCard(AppLocalizations l10n) {
    final latest = filtered.last;
    final first = filtered.first;
    final weightChange = (latest.weight - first.weight) / 1000;
    final heightChange = latest.height - first.height;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff263A78), Color(0xff4668CE), Color(0xff22A987)],
          stops: [0, .55, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: _weightColor.withAlpha(55),
            blurRadius: 28,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(28),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.growthJourney,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.measurementsByActualAge,
                      style: TextStyle(
                        color: Colors.white.withAlpha(190),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.measurementCount(filtered.length),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _summaryMetric(
                  l10n.latestMeasurement,
                  '${(latest.weight / 1000).toStringAsFixed(2)} ${l10n.unitKg}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryMetric(
                  l10n.weightChange,
                  _signedValue(weightChange, l10n.unitKg, decimals: 2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryMetric(
                  l10n.heightChange,
                  _signedValue(heightChange.toDouble(), l10n.unitCm),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: Colors.white.withAlpha(185),
              ),
              const SizedBox(width: 6),
              Text(
                '${_formatAge(_ageInDays(latest.date), l10n)} · '
                '${MaterialLocalizations.of(context).formatMediumDate(latest.date)}',
                style: TextStyle(
                  color: Colors.white.withAlpha(195),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withAlpha(22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(170),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricChart({
    required String title,
    required IconData icon,
    required Color color,
    required List<_GrowthPoint> points,
    required String unit,
    required int decimals,
    required double minimumPadding,
  }) {
    final l10n = AppLocalizations.of(context);
    if (points.isEmpty) {
      return PremiumChartCard(
        title: title,
        subtitle: l10n.measurementsByActualAge,
        trailing: _metricIcon(icon, color),
        child: SizedBox(
          height: 96,
          child: Center(
            child: Text(
              l10n.noData,
              style: graphAxisStyle(context, fontSize: 12),
            ),
          ),
        ),
      );
    }

    final values = points.map((point) => point.value).toList();
    final rawMinY = values.reduce(math.min);
    final rawMaxY = values.reduce(math.max);
    final valueRange = rawMaxY - rawMinY;
    final padding = math.max(minimumPadding, valueRange * .18);
    final interval = niceInterval(
      math.max(valueRange + padding * 2, minimumPadding * 2),
      targetLines: 4,
    );
    final minY = ((rawMinY - padding) / interval).floor() * interval;
    var maxY = ((rawMaxY + padding) / interval).ceil() * interval;
    if (maxY <= minY) maxY = minY + interval;

    final rawMinX = points.first.ageDays;
    final rawMaxX = points.last.ageDays;
    final ageRange = rawMaxX - rawMinX;
    final xPadding = ageRange == 0 ? 1.0 : math.max(1.0, ageRange * .035);
    final minX = math.max(0, rawMinX - xPadding).toDouble();
    final maxX = rawMaxX + xPadding;
    final xInterval = niceInterval(math.max(1, maxX - minX), targetLines: 4);

    final latest = points.last.value;
    final change = points.length > 1
        ? latest - points[points.length - 2].value
        : null;

    return PremiumChartCard(
      title: title,
      subtitle: l10n.tapPointForDetails,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (change != null) ...[
            _changePill(change, unit, color, decimals),
            const SizedBox(width: 8),
          ],
          _metricIcon(icon, color),
        ],
      ),
      child: SizedBox(
        height: 245,
        child: LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            clipData: const FlClipData.all(),
            gridData: premiumGrid(context, interval: interval),
            borderData: FlBorderData(show: false),
            titlesData: _titles(
              minX: minX,
              maxX: maxX,
              xInterval: xInterval,
              yInterval: interval,
              decimals: decimals,
            ),
            lineTouchData: _touchData(points, unit, color, decimals),
            lineBarsData: [
              LineChartBarData(
                spots: points
                    .map((point) => FlSpot(point.ageDays, point.value))
                    .toList(),
                isCurved: points.length > 2,
                curveSmoothness: .2,
                preventCurveOverShooting: true,
                color: color,
                barWidth: 3.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) {
                    final isLatest = index == points.length - 1;
                    return FlDotCirclePainter(
                      radius: isLatest ? 4.8 : 3.6,
                      color: Theme.of(context).cardColor,
                      strokeWidth: isLatest ? 3 : 2.4,
                      strokeColor: color,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color.withAlpha(62), color.withAlpha(3)],
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  FlTitlesData _titles({
    required double minX,
    required double maxX,
    required double xInterval,
    required double yInterval,
    required int decimals,
  }) {
    final l10n = AppLocalizations.of(context);
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 43,
          interval: yInterval,
          getTitlesWidget: (value, meta) {
            if (value == meta.max) return const SizedBox();
            final label = decimals > 0 && yInterval < 1
                ? value.toStringAsFixed(1)
                : value.round().toString();
            return SideTitleWidget(
              meta: meta,
              space: 7,
              child: Text(label, style: graphAxisStyle(context)),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        axisNameWidget: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(l10n.ageLabel, style: graphAxisStyle(context)),
        ),
        axisNameSize: 20,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 34,
          interval: xInterval,
          getTitlesWidget: (value, meta) {
            if (value < minX || value > maxX) return const SizedBox();
            return SideTitleWidget(
              meta: meta,
              space: 8,
              child: Text(
                _formatAge(value, l10n),
                style: graphAxisStyle(context),
              ),
            );
          },
        ),
      ),
    );
  }

  LineTouchData _touchData(
    List<_GrowthPoint> points,
    String unit,
    Color color,
    int decimals,
  ) {
    final l10n = AppLocalizations.of(context);
    return LineTouchData(
      handleBuiltInTouches: true,
      touchSpotThreshold: 24,
      getTouchedSpotIndicator: (bar, indexes) => indexes
          .map(
            (index) => TouchedSpotIndicatorData(
              FlLine(color: color.withAlpha(110), strokeWidth: 1.2),
              FlDotData(
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 5,
                      color: color,
                      strokeWidth: 3,
                      strokeColor: Theme.of(context).cardColor,
                    ),
              ),
            ),
          )
          .toList(),
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => const Color(0xff202535),
        tooltipBorderRadius: BorderRadius.circular(13),
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (spots) => spots.map((spot) {
          final point = points[spot.spotIndex];
          final value = decimals == 0
              ? point.value.round().toString()
              : point.value.toStringAsFixed(decimals);
          final date = MaterialLocalizations.of(
            context,
          ).formatMediumDate(point.entry.date);
          return LineTooltipItem(
            '$date\n${_formatAge(point.ageDays, l10n)} · $value $unit',
            TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _metricIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _changePill(double change, String unit, Color color, int decimals) {
    final icon = change >= 0
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            _signedValue(change, unit, decimals: decimals),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _signedValue(double value, String unit, {int decimals = 0}) {
    final sign = value > 0
        ? '+'
        : value < 0
        ? '−'
        : '';
    final number = value.abs().toStringAsFixed(decimals);
    return '$sign$number $unit';
  }
}

class _GrowthPoint {
  const _GrowthPoint(this.entry, this.ageDays, this.value);

  final GrowthEntry entry;
  final double ageDays;
  final double value;
}
