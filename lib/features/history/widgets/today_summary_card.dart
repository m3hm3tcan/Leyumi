import 'package:flutter/material.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/l10n/app_localizations.dart';

class TodaySummaryCard extends StatelessWidget {
  final List<FeedingSession> sessions;

  const TodaySummaryCard({super.key, required this.sessions});

  String _format(Duration d, AppLocalizations l10n) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);

    if (h > 0) {
      return '$h ${l10n.hoursShort} $m ${l10n.minutesShort} '
          '$s ${l10n.secondsShort}';
    }
    if (m > 0) return '$m ${l10n.minutesShort} $s ${l10n.secondsShort}';
    return '$s ${l10n.secondsShort}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalDuration = sessions.fold<Duration>(
      Duration.zero,
      (a, b) => a + b.totalDuration,
    );

    final totalMilk = sessions.fold<int>(
      0,
      (a, b) => a + (b.milkIntakeGr ?? 0),
    );

    final avgDuration = sessions.isEmpty
        ? Duration.zero
        : Duration(seconds: totalDuration.inSeconds ~/ sessions.length);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff6C63FF), Color(0xff8A7DFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff6C63FF).withOpacity(.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.today.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  decoration: TextDecoration.none,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  "${sessions.length} ${l10n.sessions}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// HERO NUMBER
          Text(
            _format(totalDuration, l10n),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              decoration: TextDecoration.none,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            l10n.totalFeedingDuration,
            style: TextStyle(
              color: Colors.white.withOpacity(.85),
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),

          const SizedBox(height: 24),

          /// METRICS
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.monitor_weight_outlined,
                  value: '$totalMilk ${l10n.unitGr} ${l10n.milk}',
                  label: l10n.milk,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  icon: Icons.schedule_rounded,
                  value: _format(avgDuration, l10n),
                  label: l10n.average,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  icon: Icons.baby_changing_station_rounded,
                  value: sessions.length.toString(),
                  label: l10n.sessions,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(.7),
              fontSize: 11,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
