import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/data/record_identity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/baby_profile.dart';
import '../../../services/baby_storage.dart';
import '../../../services/feeding_storage.dart';
import '../feeding_entry.dart';
import '../feeding_session.dart';
import '../widgets/feeding_save_dialog.dart';

class ManualFeedingSheet extends StatefulWidget {
  const ManualFeedingSheet({super.key});

  @override
  State<ManualFeedingSheet> createState() => _ManualFeedingSheetState();
}

class _ManualFeedingSheetState extends State<ManualFeedingSheet> {
  late DateTime _selectedDate;
  BabyProfile? _profile;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  double _leftRatio = .5;
  Duration _totalDuration = Duration.zero;
  Duration _leftDuration = Duration.zero;
  Duration _rightDuration = Duration.zero;
  String? _dateError;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await BabyStorage().loadProfile();
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final profile = _profile ?? await BabyStorage().loadProfile();
    if (!mounted) return;

    final firstDate = _dateOnly(profile?.birthDate ?? DateTime(now.year - 10));
    final lastDate = _dateOnly(now);
    final initialDate = _selectedDate.isBefore(firstDate)
        ? firstDate
        : _selectedDate.isAfter(lastDate)
        ? lastDate
        : _selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _dateError = null;
      _timeError = null;
      _recalculate();
    });
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      _startTime = picked;
      _timeError = null;
      _recalculate();
    });
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      _endTime = picked;
      _timeError = null;
      _recalculate();
    });
  }

  void _recalculate() {
    final range = _dateRange;
    if (range == null || range.$2.isBefore(range.$1)) {
      _totalDuration = Duration.zero;
      _leftDuration = Duration.zero;
      _rightDuration = Duration.zero;
      return;
    }

    _totalDuration = range.$2.difference(range.$1);
    _leftDuration = Duration(
      seconds: (_totalDuration.inSeconds * _leftRatio).round(),
    );
    _rightDuration = _totalDuration - _leftDuration;
  }

  (DateTime, DateTime)? get _dateRange {
    if (_startTime == null || _endTime == null) return null;
    return (
      DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime!.hour,
        _startTime!.minute,
      ),
      DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime!.hour,
        _endTime!.minute,
      ),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final profile = _profile ?? await BabyStorage().loadProfile();
    if (!mounted) return;

    final today = _dateOnly(DateTime.now());
    final birthDate = profile == null ? null : _dateOnly(profile.birthDate);
    if (_selectedDate.isAfter(today)) {
      setState(() => _dateError = l10n.futureDateTimeError);
      return;
    }
    if (birthDate != null && _selectedDate.isBefore(birthDate)) {
      setState(() => _dateError = l10n.feedingBeforeBirthError);
      return;
    }

    final range = _dateRange;
    if (range == null) {
      setState(() {
        _timeError = l10n.selectFeedingTimesError;
      });
      return;
    }
    if (!range.$2.isAfter(range.$1) || _totalDuration == Duration.zero) {
      setState(() {
        _timeError = l10n.feedingTimeOrderError;
      });
      return;
    }
    if (_totalDuration > const Duration(hours: 12)) {
      setState(() {
        _timeError = l10n.feedingDurationRangeError;
      });
      return;
    }
    if (range.$1.isAfter(DateTime.now()) || range.$2.isAfter(DateTime.now())) {
      setState(() => _timeError = l10n.futureDateTimeError);
      return;
    }

    final decision = await showFeedingSaveDialog(context);
    if (!mounted || decision == null) return;

    if (decision == FeedingSaveDecision.discard) {
      await FeedingStorage().clearActiveDraft();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final childId = profile?.id ?? RecordIdentity.legacyChildId;

    Navigator.pop(
      context,
      FeedingSession(
        childId: childId,
        startTime: range.$1,
        endTime: range.$2,
        entries: [
          FeedingEntry(side: FeedingSide.left, duration: _leftDuration),
          FeedingEntry(side: FeedingSide.right, duration: _rightDuration),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.manualFeedingEntry,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _dateRow(l10n),
            const SizedBox(height: 8),
            _timeRow(
              l10n.startTime,
              _startTime,
              _pickStart,
              hasError: _timeError != null,
            ),
            const SizedBox(height: 8),
            _timeRow(
              l10n.endTime,
              _endTime,
              _pickEnd,
              hasError: _timeError != null,
            ),
            if (_timeError != null) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _timeError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(l10n.leftRightRatio),
            Slider(
              value: _leftRatio,
              onChanged: (value) {
                setState(() {
                  _leftRatio = value;
                  _recalculate();
                });
              },
            ),
            Text(
              '${(_leftRatio * 100).toStringAsFixed(0)}% ${l10n.leftLabel} - '
              '${(100 - _leftRatio * 100).toStringAsFixed(0)}% '
              '${l10n.rightLabel}',
            ),
            const SizedBox(height: 20),
            if (_totalDuration > Duration.zero) ...[
              Text(
                '${l10n.totalLabel}: ${_totalDuration.inMinutes} '
                '${l10n.minutesShort}',
              ),
              Text(
                '${l10n.leftLabel}: ${_leftDuration.inMinutes} '
                '${l10n.minutesShort}',
              ),
              Text(
                '${l10n.rightLabel}: ${_rightDuration.inMinutes} '
                '${l10n.minutesShort}',
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 40,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.save,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _dateRow(AppLocalizations l10n) {
    final errorColor = Theme.of(context).colorScheme.error;
    final hasError = _dateError != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: hasError ? errorColor.withAlpha(12) : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? errorColor : Theme.of(context).dividerColor,
          width: hasError ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: _pickDate,
        leading: Icon(
          Icons.calendar_month_rounded,
          color: hasError ? errorColor : null,
        ),
        title: Text(l10n.feedingDate),
        subtitle: hasError
            ? Text(_dateError!, style: TextStyle(color: errorColor))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              MaterialLocalizations.of(context).formatMediumDate(_selectedDate),
            ),
            if (hasError) ...[
              const SizedBox(width: 8),
              Icon(Icons.error_rounded, color: errorColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timeRow(
    String label,
    TimeOfDay? value,
    VoidCallback onPressed, {
    required bool hasError,
  }) {
    final l10n = AppLocalizations.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: hasError ? errorColor.withAlpha(12) : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? errorColor : Theme.of(context).dividerColor,
          width: hasError ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onPressed,
        leading: Icon(
          Icons.schedule_rounded,
          color: hasError ? errorColor : null,
        ),
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value == null
                  ? l10n.select
                  : MaterialLocalizations.of(context).formatTimeOfDay(value),
            ),
            if (hasError) ...[
              const SizedBox(width: 8),
              Icon(Icons.error_rounded, color: errorColor),
            ],
          ],
        ),
      ),
    );
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
