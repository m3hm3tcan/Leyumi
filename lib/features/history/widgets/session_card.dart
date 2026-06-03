import 'package:flutter/material.dart';
import 'package:babyfeedpro/features/feeding/feeding_session.dart';

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

    if (h > 0) {
      return "${h}h ${m}m ${s}s";
    }

    if (m > 0) {
      return "${m}m ${s}s";
    }

    return "${s}s";
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final leftTotal = session.entries
        .where((e) => e.side == "left")
        .fold(Duration.zero, (a, b) => a + b.duration);

    final rightTotal = session.entries
        .where((e) => e.side == "right")
        .fold(Duration.zero, (a, b) => a + b.duration);

    final total = leftTotal + rightTotal;

    final leftRatio =
        total.inSeconds == 0 ? 0.5 : leftTotal.inSeconds / total.inSeconds;

    final milk = session.milkIntakeGr ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UIColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─────────────────────────
          // HEADER
          // ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Feeding Session",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: UIColors.muted,
                ),
              ),
              Text(
                _formatTime(session.startTime),
                style: TextStyle(
                  fontSize: 13,
                  color: UIColors.muted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ─────────────────────────
          // MAIN NUMBER (FOCUS)
          // ─────────────────────────
          Text(
            _formatDuration(session.totalDuration),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: UIColors.text,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            "Total feeding time",
            style: TextStyle(
              fontSize: 13,
              color: UIColors.muted,
            ),
          ),

          const SizedBox(height: 8),

          // ─────────────────────────
          // BALANCE BAR (LEFT / RIGHT)
          // ─────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (leftRatio * 100).toInt(),
                    child: Container(color: UIColors.left),
                  ),
                  Expanded(
                    flex: ((1 - leftRatio) * 100).toInt(),
                    child: Container(color: UIColors.right),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ─────────────────────────
          // STATS ROW
          // ─────────────────────────
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

          const SizedBox(height: 14),

          // ─────────────────────────
          // MILK BADGE
          // ─────────────────────────
          if (milk > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: UIColors.milk.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.water_drop_rounded,
                    size: 18,
                    color: UIColors.milk,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$milk g milk intake",
                    style: const TextStyle(
                      color: UIColors.milk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: UIColors.muted,
          ),
        ),
        const SizedBox(height: 4),
        Row(
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
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: UIColors.text,
              ),
            ),
          ],
        ),
      ],
    );
  }
}