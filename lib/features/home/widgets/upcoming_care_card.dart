import 'package:flutter/material.dart';

import '../../../features/care_calendar/care_calendar_screen.dart';
import '../../../features/care_calendar/care_event.dart';
import '../../../features/care_calendar/care_event_schedule.dart';
import '../../../features/care_calendar/care_event_style.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/care_event_storage.dart';
import '../../../shared/widgets/app_card.dart';

class UpcomingCareCard extends StatefulWidget {
  const UpcomingCareCard({super.key, required this.refreshVersion});

  final int refreshVersion;

  @override
  State<UpcomingCareCard> createState() => _UpcomingCareCardState();
}

class _UpcomingCareCardState extends State<UpcomingCareCard> {
  List<({CareEvent event, DateTime occurrence})> _upcoming = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant UpcomingCareCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final events = await CareEventStorage().loadEvents();
    final upcoming =
        events
            .map((event) {
              final occurrence = CareEventSchedule.nextOccurrence(event, now);
              return occurrence == null
                  ? null
                  : (event: event, occurrence: occurrence);
            })
            .whereType<({CareEvent event, DateTime occurrence})>()
            .toList()
          ..sort((a, b) => a.occurrence.compareTo(b.occurrence));
    if (!mounted) return;
    setState(() => _upcoming = upcoming.take(3).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_upcoming.isEmpty) return const SizedBox.shrink();

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(15),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_note, color: Color(0xff6558E8)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  l10n.upcomingCare,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CareCalendarScreen(),
                    ),
                  );
                  await _load();
                },
                child: Text(l10n.viewCalendar),
              ),
            ],
          ),
          for (final item in _upcoming) _eventRow(item, l10n),
        ],
      ),
    );
  }

  Widget _eventRow(
    ({CareEvent event, DateTime occurrence}) item,
    AppLocalizations l10n,
  ) {
    final color = CareEventStyle.color(item.event.type);
    final localizations = MaterialLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              CareEventStyle.icon(item.event.type),
              color: color,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${localizations.formatShortDate(item.occurrence)} \u2022 '
                  '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(item.occurrence))}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withAlpha(155),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _relative(item.occurrence, l10n),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _relative(DateTime value, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = CareEventSchedule.dateOnly(now);
    final day = CareEventSchedule.dateOnly(value);
    final difference = day.difference(today).inDays;
    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.tomorrow;
    return l10n.inDays(difference);
  }
}
