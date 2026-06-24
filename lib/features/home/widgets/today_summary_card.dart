import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../diaper/diaper_entry.dart';
import '../../feeding/feeding_session.dart';
import '../../../services/diaper_storage.dart';
import '../../../services/feeding_storage.dart';
import '../../../shared/widgets/app_card.dart';

class TodaySummaryCard extends StatefulWidget {
  const TodaySummaryCard({super.key, required this.refreshVersion});

  final int refreshVersion;

  @override
  State<TodaySummaryCard> createState() => _TodaySummaryCardState();
}

class _TodaySummaryCardState extends State<TodaySummaryCard> {
  int _feedingCount = 0;
  int _diaperCount = 0;
  DateTime? _lastActivity;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didUpdateWidget(covariant TodaySummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) _loadStats();
  }

  Future<void> _loadStats() async {
    final results = await Future.wait<dynamic>([
      FeedingStorage().loadSessions(),
      DiaperStorage().loadEntries(),
    ]);
    final feedings = results[0] as List<FeedingSession>;
    final diapers = results[1] as List<DiaperEntry>;
    final activities = <DateTime>[
      ...feedings
          .where((item) => AppDateUtils.isToday(item.startTime))
          .map((item) => item.startTime),
      ...diapers
          .where((item) => AppDateUtils.isToday(item.timestamp))
          .map((item) => item.timestamp),
    ]..sort();

    if (!mounted) return;
    setState(() {
      _feedingCount = feedings
          .where((item) => AppDateUtils.isToday(item.startTime))
          .length;
      _diaperCount = diapers
          .where((item) => AppDateUtils.isToday(item.timestamp))
          .length;
      _lastActivity = activities.isEmpty ? null : activities.last;
    });
  }

  String _relativeTime(AppLocalizations l10n) {
    if (_lastActivity == null) return '-';
    final difference = DateTime.now().difference(_lastActivity!);
    if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    }
    if (difference.inHours < 24) return l10n.hoursAgo(difference.inHours);
    return l10n.daysAgo(difference.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.todayActivities,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: l10n.feeding, value: '$_feedingCount'),
              _StatItem(label: l10n.diaper, value: '$_diaperCount'),
              _StatItem(label: l10n.last, value: _relativeTime(l10n)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withAlpha(178),
          ),
        ),
      ],
    );
  }
}
