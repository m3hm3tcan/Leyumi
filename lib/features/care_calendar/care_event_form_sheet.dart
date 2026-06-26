import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/child/active_child_provider.dart';
import '../../core/premium/premium_feature.dart';
import '../../core/premium/premium_access.dart';
import '../../core/premium/premium_provider.dart';
import '../../l10n/app_localizations.dart';
import 'care_event.dart';
import 'care_event_style.dart';

class CareEventFormSheet extends StatefulWidget {
  const CareEventFormSheet({super.key, this.initialEvent});

  final CareEvent? initialEvent;

  @override
  State<CareEventFormSheet> createState() => _CareEventFormSheetState();
}

class _CareEventFormSheetState extends State<CareEventFormSheet> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  final _dosageController = TextEditingController();
  final _titleFocus = FocusNode();

  late CareEventType _type;
  late DateTime _dateTime;
  late CareEventRecurrence _recurrence;
  String? _titleError;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final event = widget.initialEvent;
    _type = event?.type ?? CareEventType.doctor;
    _dateTime =
        event?.scheduledAt ?? DateTime.now().add(const Duration(days: 1));
    _recurrence = event?.recurrence ?? CareEventRecurrence.none;
    _titleController.text = event?.title ?? '';
    _locationController.text = event?.location ?? '';
    _noteController.text = event?.note ?? '';
    _dosageController.text = event?.dosage ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    _dosageController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final profile = context.read<ActiveChildProvider>().activeChild;
    final now = DateTime.now();
    final firstDate = profile?.birthDate ?? DateTime(now.year - 10);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTime.isBefore(firstDate) ? firstDate : _dateTime,
      firstDate: DateTime(firstDate.year, firstDate.month, firstDate.day),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dateTime.hour,
        _dateTime.minute,
      );
      _dateError = null;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (picked == null) return;
    setState(() {
      _dateTime = DateTime(
        _dateTime.year,
        _dateTime.month,
        _dateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final profile = context.read<ActiveChildProvider>().activeChild;
    final premium = context.read<PremiumProvider>();
    final hasAdvanced = premium.hasAccess(PremiumFeature.advancedCarePlanning);
    final title = _titleController.text.trim();
    final beforeBirth =
        profile != null &&
        DateTime(_dateTime.year, _dateTime.month, _dateTime.day).isBefore(
          DateTime(
            profile.birthDate.year,
            profile.birthDate.month,
            profile.birthDate.day,
          ),
        );

    if (!hasAdvanced && _isPremiumOnlyType(_type)) {
      _openPremium();
      return;
    }

    setState(() {
      _titleError = title.length < 2 ? l10n.careTitleError : null;
      _dateError = beforeBirth ? l10n.careBeforeBirthError : null;
    });
    if (_titleError != null) {
      _titleFocus.requestFocus();
      return;
    }
    if (_dateError != null || profile == null) return;

    final initial = widget.initialEvent;
    Navigator.pop(
      context,
      CareEvent(
        id: initial?.id,
        childId: profile.id,
        type: _type,
        title: title,
        scheduledAt: _dateTime,
        status: initial?.status ?? CareEventStatus.scheduled,
        recurrence: hasAdvanced ? _recurrence : CareEventRecurrence.none,
        location: _nullIfEmpty(_locationController.text),
        note: _nullIfEmpty(_noteController.text),
        dosage: hasAdvanced && _type == CareEventType.medicine
            ? _nullIfEmpty(_dosageController.text)
            : null,
        reminderMinutesBefore: initial?.reminderMinutesBefore,
        createdAt: initial?.createdAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final premium = context.watch<PremiumProvider>();
    final hasAdvanced = premium.hasAccess(PremiumFeature.advancedCarePlanning);
    final media = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * .92),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + media.viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.initialEvent == null
                  ? l10n.addCareEvent
                  : l10n.editCareEvent,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            Text(l10n.eventType, style: _labelStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CareEventType.values.map((type) {
                final selected = type == _type;
                final color = CareEventStyle.color(type);
                final locked = !hasAdvanced && _isPremiumOnlyType(type);
                return ChoiceChip(
                  selected: selected,
                  avatar: Icon(
                    locked ? Icons.lock : CareEventStyle.icon(type),
                    size: 17,
                    color: locked ? Theme.of(context).disabledColor : color,
                  ),
                  label: Text(
                    locked
                        ? '${_typeLabel(type, l10n)} - ${l10n.premiumPlan}'
                        : _typeLabel(type, l10n),
                  ),
                  onSelected: (_) {
                    if (locked) {
                      _openPremium();
                      return;
                    }
                    setState(() => _type = type);
                  },
                  selectedColor: color.withAlpha(28),
                  disabledColor: Theme.of(context).disabledColor.withAlpha(14),
                  side: BorderSide(
                    color: selected
                        ? color
                        : locked
                        ? Theme.of(context).disabledColor.withAlpha(80)
                        : Theme.of(context).dividerColor.withAlpha(80),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              focusNode: _titleFocus,
              maxLength: 60,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_titleError != null) setState(() => _titleError = null);
              },
              decoration: _decoration(
                l10n.eventTitle,
                Icons.title,
                errorText: _titleError,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dateTimeTile(
                    label: l10n.dateAndTime,
                    value: MaterialLocalizations.of(
                      context,
                    ).formatMediumDate(_dateTime),
                    icon: Icons.event,
                    onTap: _pickDate,
                    errorText: _dateError,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dateTimeTile(
                    label: l10n.startTime,
                    value: MaterialLocalizations.of(
                      context,
                    ).formatTimeOfDay(TimeOfDay.fromDateTime(_dateTime)),
                    icon: Icons.access_time,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _locationController,
              maxLength: 80,
              decoration: _decoration(l10n.doctorOrLocation, Icons.place),
            ),
            if (_type == CareEventType.medicine) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _dosageController,
                maxLength: 40,
                enabled: hasAdvanced,
                decoration: _decoration(
                  l10n.medicineDosage,
                  Icons.local_pharmacy,
                  suffix: hasAdvanced ? null : const Icon(Icons.lock),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLength: 300,
              maxLines: 3,
              inputFormatters: [LengthLimitingTextInputFormatter(300)],
              decoration: _decoration(l10n.note, Icons.notes),
            ),
            const SizedBox(height: 12),
            _premiumSelector(
              title: l10n.repeatPlan,
              value: _recurrenceLabel(_recurrence, l10n),
              locked: !hasAdvanced,
              onTap: () =>
                  hasAdvanced ? _selectRecurrence(true) : _openPremium(),
            ),
            if (!hasAdvanced) ...[
              const SizedBox(height: 8),
              Text(
                l10n.advancedCarePremiumHint,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.event_available),
                label: Text(l10n.save),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectRecurrence(bool enabled) async {
    if (!enabled) return;
    final selected = await showModalBottomSheet<CareEventRecurrence>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: CareEventRecurrence.values
                .map(
                  (value) => RadioListTile<CareEventRecurrence>(
                    value: value,
                    groupValue: _recurrence,
                    title: Text(_recurrenceLabel(value, l10n)),
                    onChanged: (choice) => Navigator.pop(context, choice),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    if (selected != null) setState(() => _recurrence = selected);
  }

  Future<void> _openPremium() {
    return PremiumAccess.open(
      context,
      feature: PremiumFeature.advancedCarePlanning,
      builder: (_) => const SizedBox.shrink(),
    );
  }

  Widget _premiumSelector({
    required String title,
    required String value,
    required bool locked,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Theme.of(context).dividerColor.withAlpha(70)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(value),
      trailing: Icon(locked ? Icons.lock : Icons.chevron_right),
    );
  }

  Widget _dateTimeTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    String? errorText,
  }) {
    final error = Theme.of(context).colorScheme.error;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: errorText == null
              ? Theme.of(context).dividerColor.withAlpha(70)
              : error,
          width: errorText == null ? 1 : 2,
        ),
      ),
      leading: Icon(icon, color: errorText == null ? null : error),
      title: Text(label, style: const TextStyle(fontSize: 11)),
      subtitle: Text(
        errorText ?? value,
        style: TextStyle(color: errorText == null ? null : error),
      ),
    );
  }

  InputDecoration _decoration(
    String label,
    IconData icon, {
    String? errorText,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  String _typeLabel(CareEventType type, AppLocalizations l10n) =>
      switch (type) {
        CareEventType.vaccine => l10n.careTypeVaccine,
        CareEventType.doctor => l10n.careTypeDoctor,
        CareEventType.medicine => l10n.careTypeMedicine,
        CareEventType.checkup => l10n.careTypeCheckup,
        CareEventType.laboratory => l10n.careTypeLaboratory,
        CareEventType.therapy => l10n.careTypeTherapy,
        CareEventType.custom => l10n.careTypeCustom,
      };

  String _recurrenceLabel(CareEventRecurrence value, AppLocalizations l10n) =>
      switch (value) {
        CareEventRecurrence.none => l10n.repeatNone,
        CareEventRecurrence.daily => l10n.repeatDaily,
        CareEventRecurrence.weekly => l10n.repeatWeekly,
        CareEventRecurrence.monthly => l10n.repeatMonthly,
      };

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  bool _isPremiumOnlyType(CareEventType type) =>
      type == CareEventType.medicine ||
      type == CareEventType.laboratory ||
      type == CareEventType.therapy;

  TextStyle get _labelStyle =>
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w800);
}
