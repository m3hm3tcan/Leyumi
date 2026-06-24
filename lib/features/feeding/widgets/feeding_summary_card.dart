import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../feeding_entry.dart';

class FeedingSummaryCard extends StatelessWidget {
  const FeedingSummaryCard({super.key, required this.entries});

  final List<FeedingEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final left = entries
        .where((entry) => entry.side == FeedingSide.left)
        .fold(Duration.zero, (sum, entry) => sum + entry.duration);
    final right = entries
        .where((entry) => entry.side == FeedingSide.right)
        .fold(Duration.zero, (sum, entry) => sum + entry.duration);
    final total = left + right;
    final leftRatio = total.inSeconds == 0
        ? .5
        : left.inSeconds / total.inSeconds;
    final rightRatio = 1 - leftRatio;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.feedingSummary,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Expanded(
                  flex: (leftRatio * 1000).round().clamp(1, 999).toInt(),
                  child: Container(height: 12, color: Colors.pink),
                ),
                Expanded(
                  flex: (rightRatio * 1000).round().clamp(1, 999).toInt(),
                  child: Container(height: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SideValue(
                label: l10n.leftLabel,
                ratio: leftRatio,
                duration: left,
                color: Colors.pink,
                alignEnd: false,
              ),
              _SideValue(
                label: l10n.rightLabel,
                ratio: rightRatio,
                duration: right,
                color: Colors.blue,
                alignEnd: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${l10n.totalLabel}: ${_format(total)}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static String _format(Duration duration) =>
      '${duration.inMinutes.toString().padLeft(2, '0')}:'
      '${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
}

class _SideValue extends StatelessWidget {
  const _SideValue({
    required this.label,
    required this.ratio,
    required this.duration,
    required this.color,
    required this.alignEnd,
  });

  final String label;
  final double ratio;
  final Duration duration;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: color),
        ),
        Text(
          '${(ratio * 100).toStringAsFixed(0)}%',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        Text(
          FeedingSummaryCard._format(duration),
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ],
    );
  }
}
