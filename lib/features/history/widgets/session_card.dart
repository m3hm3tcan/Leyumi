import 'package:flutter/material.dart';
import 'package:babyfeedpro/features/feeding/feeding_session.dart';
import 'package:babyfeedpro/features/feeding/feeding_entry.dart';

class UIColors {
  static const bg = Color(0xffF6F7FB);
  static const card = Colors.white;

  static const text = Color(0xff111827);
  static const muted = Color(0xff6B7280);

  static const left = Color(0xffFF6B9D);
  static const right = Color(0xff4DA3FF);

  static const milk = Color(0xff22C55E);
}

class SessionCard extends StatelessWidget {
  final FeedingSession session;

  const SessionCard({
    super.key,
    required this.session,
  });

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);

    if (h > 0) return "${h}h ${m}m ${s}s";
    if (m > 0) return "${m}m ${s}s";
    return "${s}s";
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final leftTotal = session.entries
        .where((e) => e.side == FeedingSide.left)
        .fold(Duration.zero, (a, b) => a + b.duration);

    final rightTotal = session.entries
        .where((e) => e.side == FeedingSide.right)
        .fold(Duration.zero, (a, b) => a + b.duration);

    final total = leftTotal + rightTotal;

    final leftRatio =
        total.inSeconds == 0 ? 0.5 : leftTotal.inSeconds / total.inSeconds;

    final leftFlex = (leftRatio * 100).round().clamp(1, 99);
    final rightFlex = 100 - leftFlex;

    final milk = session.milkIntakeGr ?? 0;

    return Container(
      margin: const EdgeInsets.only(
        right: 16,
        bottom: 12,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UIColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 14,
                color: UIColors.muted,
              ),
              const SizedBox(width: 4),
              Text(
                _formatTime(session.startTime),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: UIColors.muted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// MAIN VALUE
          Text(
            _formatDuration(session.totalDuration),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: UIColors.text,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 1),

          const Text(
            "Total feeding time",
            style: TextStyle(
              fontSize: 12,
              color: UIColors.muted,
            ),
          ),

          const SizedBox(height: 6),

          /// BALANCE BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: leftFlex,
                    child: Container(color: UIColors.left),
                  ),
                  Expanded(
                    flex: rightFlex,
                    child: Container(color: UIColors.right),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// LEFT / RIGHT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat(
                label: "Left",
                value: _formatDuration(leftTotal),
                color: UIColors.left,
              ),
              _miniStat(
                label: "Right",
                value: _formatDuration(rightTotal),
                color: UIColors.right,
              ),
            ],
          ),

          if (milk > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: UIColors.milk.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.water_drop_rounded,
                    size: 16,
                    color: UIColors.milk,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$milk g milk",
                    style: const TextStyle(
                      color: UIColors.milk,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "$label • $value",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: UIColors.text,
          ),
        ),
      ],
    );
  }
}