import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../diaper/diaper_entry.dart';
import '../../feeding/feeding_entry.dart';
import '../../feeding/bottle_portion.dart';
import '../home_dashboard_service.dart';
import '../home_dashboard_snapshot.dart';

class TodaySummaryCard extends StatefulWidget {
  const TodaySummaryCard({
    super.key,
    required this.childId,
    required this.refreshVersion,
    this.loader = const HomeDashboardService(),
  });

  final String childId;
  final int refreshVersion;
  final HomeDashboardLoader loader;

  @override
  State<TodaySummaryCard> createState() => _TodaySummaryCardState();
}

class _TodaySummaryCardState extends State<TodaySummaryCard> {
  HomeDashboardSnapshot? _snapshot;
  Object? _loadError;
  bool _loading = true;
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didUpdateWidget(covariant TodaySummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion ||
        oldWidget.childId != widget.childId) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    final requestVersion = ++_requestVersion;
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final snapshot = await widget.loader.load(childId: widget.childId);
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestVersion != _requestVersion) return;
      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_loading && _snapshot == null) return _LoadingCard(l10n: l10n);
    if (_loadError != null && _snapshot == null) {
      return _ErrorCard(l10n: l10n, onRetry: _loadStats);
    }

    final snapshot = _snapshot!;
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            _SummaryHeader(snapshot: snapshot, l10n: l10n),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                children: [
                  _ActivityTile.feeding(snapshot: snapshot, l10n: l10n),
                  const SizedBox(height: 10),
                  _ActivityTile.diaper(snapshot: snapshot, l10n: l10n),
                  if (_loadError != null) ...[
                    const SizedBox(height: 10),
                    _InlineRefreshError(l10n: l10n, onRetry: _loadStats),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.snapshot, required this.l10n});

  final HomeDashboardSnapshot snapshot;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff665BE7), Color(0xff9A65D7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(35)),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.todayAtAGlance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.todayRecordSummary(
                        snapshot.todayFeedingCount,
                        snapshot.todayDiaperCount,
                      ),
                      style: TextStyle(
                        color: Colors.white.withAlpha(215),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (snapshot.todayFeedingDuration > Duration.zero) ...[
            const SizedBox(height: 13),
            _HeaderPill(
              icon: Icons.timer_outlined,
              label: l10n.todayFeedingDuration(
                _formatDuration(snapshot.todayFeedingDuration, l10n),
              ),
            ),
          ],
          if (snapshot.todayFormulaMl > 0 || snapshot.todayExpressedMl > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (snapshot.todayFormulaMl > 0)
                  _HeaderPill(
                    icon: Icons.local_drink_outlined,
                    label:
                        '${l10n.feedingFormula}: ${snapshot.todayFormulaMl} ml',
                  ),
                if (snapshot.todayExpressedMl > 0)
                  _HeaderPill(
                    icon: Icons.water_drop_outlined,
                    label:
                        '${l10n.feedingExpressed}: ${snapshot.todayExpressedMl} ml',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(31),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.time,
  });

  factory _ActivityTile.feeding({
    required HomeDashboardSnapshot snapshot,
    required AppLocalizations l10n,
  }) {
    final session = snapshot.lastFeeding;
    final sides = session?.entries.map((entry) => entry.side).toSet();
    final side = sides == null || sides.isEmpty
        ? null
        : sides.length > 1
        ? '${l10n.leftLabel} / ${l10n.rightLabel}'
        : sides.single == FeedingSide.left
        ? l10n.leftLabel
        : l10n.rightLabel;
    final detail = session == null
        ? l10n.noFeedingRecordedYet
        : session.bottles.isNotEmpty
        ? [
            if (session.hasBreastfeeding)
              _formatDuration(session.totalDuration, l10n),
            for (final milk in BottleMilk.values)
              if (session.amountFor(milk) > 0)
                '${milk == BottleMilk.formula ? l10n.feedingFormula : l10n.feedingExpressed} ${session.amountFor(milk)} ml',
          ].join(' · ')
        : side == null
        ? _formatDuration(session.totalDuration, l10n)
        : l10n.lastFeedingDetail(
            side,
            _formatDuration(session.totalDuration, l10n),
          );
    return _ActivityTile(
      icon: Icons.favorite_rounded,
      color: const Color(0xffF26B8A),
      title: l10n.lastFeeding,
      detail: detail,
      time: session == null ? null : _relativeTime(session.startTime, l10n),
    );
  }

  factory _ActivityTile.diaper({
    required HomeDashboardSnapshot snapshot,
    required AppLocalizations l10n,
  }) {
    final entry = snapshot.lastDiaper;
    final detail = entry == null
        ? l10n.noDiaperRecordedYet
        : switch (entry.type) {
            DiaperType.pee => l10n.pee,
            DiaperType.poop => l10n.poop,
            DiaperType.both => l10n.peeAndPoop,
          };
    return _ActivityTile(
      icon: Icons.baby_changing_station_rounded,
      color: const Color(0xff38AFA9),
      title: l10n.lastDiaperChange,
      detail: detail,
      time: entry == null ? null : _relativeTime(entry.timestamp, l10n),
    );
  }

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final String? time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(theme.brightness == Brightness.dark ? 24 : 13),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withAlpha(35)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withAlpha(185)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(45),
                  blurRadius: 9,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(165),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (time != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                time!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      child: Row(
        children: [
          const SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 14),
          Text(l10n.loading),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.l10n, required this.onRetry});

  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      child: _InlineRefreshError(l10n: l10n, onRetry: onRetry),
    );
  }
}

class _InlineRefreshError extends StatelessWidget {
  const _InlineRefreshError({required this.l10n, required this.onRetry});

  final AppLocalizations l10n;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(l10n.dashboardLoadFailed)),
        TextButton(onPressed: onRetry, child: Text(l10n.retry)),
      ],
    );
  }
}

String _relativeTime(DateTime timestamp, AppLocalizations l10n) {
  final difference = DateTime.now().difference(timestamp);
  if (difference.isNegative || difference.inMinutes < 1) return l10n.justNow;
  if (difference.inMinutes < 60) return l10n.minutesAgo(difference.inMinutes);
  if (difference.inHours < 24) return l10n.hoursAgo(difference.inHours);
  return l10n.daysAgo(difference.inDays);
}

String _formatDuration(Duration duration, AppLocalizations l10n) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) return l10n.durationHoursMinutes(hours, minutes);
  return l10n.durationMinutes(minutes);
}
