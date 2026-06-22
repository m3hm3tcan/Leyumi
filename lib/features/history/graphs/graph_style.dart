import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const graphBlue = Color(0xff4F7DFF);
const graphPink = Color(0xffF46B9B);
const graphGreen = Color(0xff36B37E);
const graphPurple = Color(0xff8B6BE8);
const graphAmber = Color(0xffF3A83B);

double niceInterval(double maximum, {int targetLines = 4}) {
  if (maximum <= 0) return 1;
  final rough = maximum / targetLines;
  final power = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
  final normalized = rough / power;
  final nice = normalized <= 1
      ? 1
      : normalized <= 2
      ? 2
      : normalized <= 5
      ? 5
      : 10;
  return nice * power;
}

double chartMaximum(Iterable<double> values, {double minimum = 1}) {
  if (values.isEmpty) return minimum;
  final highest = values.reduce(math.max);
  final interval = niceInterval(math.max(highest, minimum));
  return math.max(minimum, (highest / interval).ceil() * interval);
}

int labelStep(int itemCount, {int maxLabels = 5}) {
  if (itemCount <= maxLabels) return 1;
  return (itemCount / maxLabels).ceil();
}

bool shouldShowLabel(int index, int itemCount, {int maxLabels = 5}) {
  if (index == 0 || index == itemCount - 1) return true;
  return index % labelStep(itemCount, maxLabels: maxLabels) == 0;
}

String compactDate(DateTime date, BuildContext context) {
  return MaterialLocalizations.of(context).formatShortMonthDay(date);
}

TextStyle graphAxisStyle(BuildContext context, {double fontSize = 10}) {
  final color =
      Theme.of(context).textTheme.bodySmall?.color?.withAlpha(155) ??
      Colors.grey;
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
  );
}

FlGridData premiumGrid(BuildContext context, {required double interval}) {
  final theme = Theme.of(context);
  final color = theme.dividerColor.withAlpha(
    theme.brightness == Brightness.dark ? 42 : 55,
  );
  return FlGridData(
    show: true,
    drawVerticalLine: false,
    horizontalInterval: interval,
    getDrawingHorizontalLine: (_) =>
        FlLine(color: color, strokeWidth: 1, dashArray: const [4, 5]),
  );
}

class GraphFilterBar extends StatelessWidget {
  const GraphFilterBar({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.accent = graphBlue,
  });

  final String value;
  final List<(String, String)> options;
  final ValueChanged<String> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = theme.dividerColor.withAlpha(
      theme.brightness == Brightness.dark ? 70 : 105,
    );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: options.map((option) {
          final selected = value == option.$2;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(option.$2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: accent.withAlpha(55),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  option.$1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color?.withAlpha(175),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PremiumChartCard extends StatelessWidget {
  const PremiumChartCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withAlpha(isDark ? 55 : 70),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 38 : 12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color?.withAlpha(
                            155,
                          ),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class GraphLegend extends StatelessWidget {
  const GraphLegend({
    super.key,
    required this.items,
    this.alignment = WrapAlignment.start,
  });

  final List<(Color, String)> items;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: alignment,
      spacing: 16,
      runSpacing: 8,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: item.$1, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              item.$2,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withAlpha(175),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
