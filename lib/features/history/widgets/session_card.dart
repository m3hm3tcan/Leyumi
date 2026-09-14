import 'package:leyumi/features/feeding/feeding_entry.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class UIColors {
  static const text = Color(0xff111827);
  static const muted = Color(0xff6B7280);
  static const left = Color(0xffFF6B9D);
  static const right = Color(0xff4DA3FF);
  static const milk = Color(0xff22C55E);
}

class SessionCard extends StatelessWidget {
  final FeedingSession session;
  final VoidCallback? onEdit;

  const SessionCard({super.key, required this.session, this.onEdit});

  String _formatDuration(Duration duration, AppLocalizations l10n) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);

    if (h > 0) {
      return '$h ${l10n.hoursShort} $m ${l10n.minutesShort} '
          '$s ${l10n.secondsShort}';
    }
    if (m > 0) return '$m ${l10n.minutesShort} $s ${l10n.secondsShort}';
    return '$s ${l10n.secondsShort}';
  }

  String _formatTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? UIColors.muted;
    final primaryTextColor = theme.textTheme.bodyLarge?.color ?? UIColors.text;

    final leftTotal = session.entries
        .where((entry) => entry.side == FeedingSide.left)
        .fold(Duration.zero, (a, b) => a + b.duration);

    final rightTotal = session.entries
        .where((entry) => entry.side == FeedingSide.right)
        .fold(Duration.zero, (a, b) => a + b.duration);

    final total = leftTotal + rightTotal;
    final leftRatio = total.inSeconds == 0
        ? 0.5
        : leftTotal.inSeconds / total.inSeconds;
    final leftFlex = (leftRatio * 100).round().clamp(1, 99);
    final rightFlex = 100 - leftFlex;
    final milk = session.milkIntakeGr ?? 0;

    return Container(
      margin: const EdgeInsets.only(right: 16, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withAlpha(isDark ? 220 : 250),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xff4DA3FF).withAlpha(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 38 : 10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff4DA3FF).withAlpha(22),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: Color(0xff4DA3FF),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatTime(session.startTime),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff4DA3FF),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (onEdit != null) ...[
                Tooltip(
                  message: l10n.edit,
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xff4DA3FF).withAlpha(18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Color(0xff4DA3FF),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.swipe_left_rounded,
                color: secondaryTextColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatDuration(session.totalDuration, l10n),
            style: TextStyle(
              fontSize: 28,
              height: 1,
              fontWeight: FontWeight.w900,
              color: primaryTextColor,
              letterSpacing: -0.5,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            l10n.totalFeedingTime,
            style: TextStyle(
              fontSize: 12,
              color: secondaryTextColor,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 10,
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
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  context: context,
                  label: l10n.leftLabel,
                  value: _formatDuration(leftTotal, l10n),
                  color: UIColors.left,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniStat(
                  context: context,
                  label: l10n.rightLabel,
                  value: _formatDuration(rightTotal, l10n),
                  color: UIColors.right,
                ),
              ),
            ],
          ),
          if (milk > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: UIColors.milk.withAlpha(26),
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
                    '$milk ${l10n.unitGr} ${l10n.milk}',
                    style: const TextStyle(
                      color: UIColors.milk,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      decoration: TextDecoration.none,
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
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    final primaryTextColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? UIColors.text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "$label - $value",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
