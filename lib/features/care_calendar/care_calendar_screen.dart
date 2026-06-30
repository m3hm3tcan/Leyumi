import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/child/active_child_app_bar_title.dart';
import '../../core/child/active_child_aware.dart';
import '../../core/premium/premium_feature.dart';
import '../../core/premium/premium_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/care_notification_service.dart';
import '../../services/care_event_storage.dart';
import '../history/helpers/delete_confirmation.dart';
import 'care_event.dart';
import 'care_event_form_sheet.dart';
import 'care_event_schedule.dart';
import 'care_event_style.dart';

class CareCalendarScreen extends StatefulWidget {
  const CareCalendarScreen({super.key});

  @override
  State<CareCalendarScreen> createState() => _CareCalendarScreenState();
}

class _CareCalendarScreenState extends State<CareCalendarScreen>
    with ActiveChildAware<CareCalendarScreen> {
  final _storage = CareEventStorage();
  List<CareEvent> _events = [];
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = CareEventSchedule.dateOnly(DateTime.now());
  bool _loading = true;

  @override
  Future<void> onActiveChildChanged() => _load();

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final events = await _storage.loadEvents();
    if (!mounted) return;
    setState(() {
      _events = events;
      _loading = false;
    });
  }

  Future<void> _openForm([CareEvent? event]) async {
    final result = await showModalBottomSheet<CareEvent>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CareEventFormSheet(initialEvent: event),
    );
    if (result == null) return;
    final l10n = AppLocalizations.of(context);
    await _storage.save(result);
    await _syncNotification(result, l10n);
    await _load();
    if (!mounted) return;
    setState(() {
      _selectedDay = CareEventSchedule.dateOnly(result.scheduledAt);
      _visibleMonth = DateTime(
        result.scheduledAt.year,
        result.scheduledAt.month,
      );
    });
  }

  Future<void> _delete(CareEvent event) async {
    if (!await confirmHistoryDelete(context)) return;
    await CareNotificationService.instance.cancelCareEvent(event.id);
    await _storage.delete(event.id);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).entryDeleted)),
    );
  }

  Future<void> _setStatus(CareEvent event, CareEventStatus status) async {
    final l10n = AppLocalizations.of(context);
    final updated = event.copyWith(status: status);
    await _storage.save(updated);
    await _syncNotification(updated, l10n);
    await _load();
  }

  Future<void> _syncNotification(CareEvent event, AppLocalizations l10n) async {
    final premium = context.read<PremiumProvider>();
    if (event.reminderMinutesBefore != null &&
        premium.hasAccess(PremiumFeature.smartReminders)) {
      await _maybeExplainExactAlarmPermission(l10n);
      if (!mounted) return;
    }
    final scheduledCount = await CareNotificationService.instance
        .scheduleCareEvent(
          event: event,
          enabled: premium.hasAccess(PremiumFeature.smartReminders),
          reminderTitle: l10n.reminder,
        );
    if (!mounted || event.reminderMinutesBefore == null) return;

    final message = scheduledCount > 0
        ? l10n.reminderScheduled
        : _reminderTimeHasPassed(event)
        ? l10n.reminderTimeAlreadyPassed
        : l10n.reminderCouldNotBeScheduled;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _maybeExplainExactAlarmPermission(AppLocalizations l10n) async {
    final service = CareNotificationService.instance;
    if (await service.canScheduleExactAlarms()) return;
    if (!mounted) return;

    final openSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.exactAlarmPermissionTitle),
        content: Text(l10n.exactAlarmPermissionContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.later),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );

    if (openSettings == true) {
      await service.requestExactAlarmPermission();
    }
  }

  bool _reminderTimeHasPassed(CareEvent event) {
    final minutesBefore = event.reminderMinutesBefore;
    if (minutesBefore == null) return false;
    final reminderAt = event.scheduledAt.subtract(
      Duration(minutes: minutesBefore),
    );
    return reminderAt.isBefore(DateTime.now()) ||
        reminderAt.isAtSameMomentAs(DateTime.now());
  }

  List<CareEvent> get _selectedEvents =>
      _events
          .where((event) => CareEventSchedule.occursOn(event, _selectedDay))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: ActiveChildAppBarTitle(title: l10n.careCalendar)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: Text(l10n.addCareEvent),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  _monthCalendar(l10n),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          MaterialLocalizations.of(
                            context,
                          ).formatMediumDate(_selectedDay),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '${_selectedEvents.length}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_selectedEvents.isEmpty)
                    _emptyDay(l10n)
                  else
                    for (final event in _selectedEvents)
                      _eventCard(event, l10n),
                ],
              ),
            ),
    );
  }

  Widget _monthCalendar(AppLocalizations l10n) {
    final first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final dayCount = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final leading = first.weekday - DateTime.monday;
    final totalCells = ((leading + dayCount + 6) ~/ 7) * 7;
    final localizations = MaterialLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(55)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  localizations.formatMonthYear(_visibleMonth),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(7, (index) {
              return Expanded(
                child: Text(
                  localizations.narrowWeekdays[(index + 1) % 7],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withAlpha(145),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: .82,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final dayNumber = index - leading + 1;
              if (dayNumber < 1 || dayNumber > dayCount) {
                return const SizedBox.shrink();
              }
              final day = DateTime(
                _visibleMonth.year,
                _visibleMonth.month,
                dayNumber,
              );
              return _dayCell(day);
            },
          ),
        ],
      ),
    );
  }

  Widget _dayCell(DateTime day) {
    final selected = CareEventSchedule.dateOnly(
      day,
    ).isAtSameMomentAs(_selectedDay);
    final today = CareEventSchedule.dateOnly(
      day,
    ).isAtSameMomentAs(CareEventSchedule.dateOnly(DateTime.now()));
    final events = _events
        .where((event) => CareEventSchedule.occursOn(event, day))
        .take(3)
        .toList();
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => setState(() => _selectedDay = day),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: selected ? primary.withAlpha(22) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? primary
                : today
                ? primary.withAlpha(90)
                : Colors.transparent,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected || today
                    ? FontWeight.w900
                    : FontWeight.w600,
                color: selected ? primary : null,
              ),
            ),
            const Spacer(),
            if (events.isNotEmpty)
              Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: events
                    .map(
                      (event) => Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: CareEventStyle.color(event.type),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _eventCard(CareEvent event, AppLocalizations l10n) {
    final color = CareEventStyle.color(event.type);
    final localizations = MaterialLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(48)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(24),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(CareEventStyle.icon(event.type), color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    localizations.formatTimeOfDay(
                      TimeOfDay.fromDateTime(event.scheduledAt),
                    ),
                    if (event.location != null) event.location!,
                    if (event.dosage != null) event.dosage!,
                  ].join(' \u2022 '),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withAlpha(165),
                  ),
                ),
                if (event.status != CareEventStatus.scheduled) ...[
                  const SizedBox(height: 5),
                  Text(
                    _statusLabel(event.status, l10n),
                    style: TextStyle(
                      color: event.status == CareEventStatus.completed
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'complete') {
                _setStatus(event, CareEventStatus.completed);
              } else if (value == 'cancel') {
                _setStatus(event, CareEventStatus.cancelled);
              } else if (value == 'edit') {
                _openForm(event);
              } else if (value == 'delete') {
                _delete(event);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'complete', child: Text(l10n.markCompleted)),
              PopupMenuItem(value: 'cancel', child: Text(l10n.markCancelled)),
              PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
              PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyDay(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 38,
            color: Theme.of(context).colorScheme.primary.withAlpha(150),
          ),
          const SizedBox(height: 8),
          Text(l10n.noCareEventsForDay),
        ],
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      _selectedDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    });
  }

  String _statusLabel(CareEventStatus status, AppLocalizations l10n) =>
      switch (status) {
        CareEventStatus.scheduled => l10n.statusScheduled,
        CareEventStatus.completed => l10n.statusCompleted,
        CareEventStatus.cancelled => l10n.statusCancelled,
      };
}
