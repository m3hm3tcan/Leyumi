import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/data/record_identity.dart';
import '../../../l10n/app_localizations.dart';
import '../milk_batch.dart';

class AddMilkBatchSheet extends StatefulWidget {
  const AddMilkBatchSheet({
    super.key,
    required this.suggestedLabel,
    required this.existingLabels,
    this.childId = RecordIdentity.legacyChildId,
    this.existingBatch,
  });

  final String suggestedLabel;
  final Set<String> existingLabels;
  final String childId;
  final MilkBatch? existingBatch;

  @override
  State<AddMilkBatchSheet> createState() => _AddMilkBatchSheetState();
}

class _AddMilkBatchSheetState extends State<AddMilkBatchSheet> {
  late final TextEditingController _labelController;
  late final TextEditingController _amountController;
  DateTime _expressedAt = DateTime.now();
  MilkStorageLocation _location = MilkStorageLocation.refrigerator;
  MilkSourceSide _source = MilkSourceSide.unspecified;
  double _amount = 120;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingBatch;
    _amount = (existing?.remainingAmountMl ?? 120).toDouble();
    _expressedAt = existing?.expressedAt ?? DateTime.now();
    _location = existing?.storageLocation ?? MilkStorageLocation.refrigerator;
    _source = existing?.sourceSide ?? MilkSourceSide.unspecified;
    _labelController = TextEditingController(
      text: existing?.labelNumber ?? widget.suggestedLabel,
    );
    _amountController = TextEditingController(text: _amount.round().toString());
  }

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expressedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expressedAt),
    );
    if (time == null) return;

    setState(() {
      _expressedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final label = _labelController.text.trim();
    final amount = int.tryParse(_amountController.text);

    if (label.isEmpty || amount == null || amount <= 0 || amount > 500) {
      _showMessage(l10n.invalidMilkEntry);
      return;
    }
    if (widget.existingLabels.any(
      (existing) => existing.toLowerCase() == label.toLowerCase(),
    )) {
      _showMessage(l10n.duplicateMilkLabel);
      return;
    }

    Navigator.pop(context, _buildBatch(label, amount));
  }

  MilkBatch _buildBatch(String label, int amount) {
    final existing = widget.existingBatch;
    if (existing == null) {
      return MilkBatch(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        childId: widget.childId,
        labelNumber: label,
        initialAmountMl: amount,
        remainingAmountMl: amount,
        expressedAt: _expressedAt,
        storageLocation: _location,
        sourceSide: _source,
        createdAt: DateTime.now(),
      );
    }

    return existing.copyWith(
      labelNumber: label,
      initialAmountMl: math.max(existing.initialAmountMl, amount).toInt(),
      remainingAmountMl: amount,
      expressedAt: _expressedAt,
      storageLocation: _location,
      sourceSide: _source,
      status: MilkBatchStatus.active,
      frozenAt: _location == MilkStorageLocation.freezer
          ? existing.frozenAt
          : null,
      clearFrozenAt: _location == MilkStorageLocation.refrigerator,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * .9),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + media.viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dragHandle(),
            const SizedBox(height: 18),
            Text(
              widget.existingBatch == null ? l10n.addMilk : l10n.editMilkRecord,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 5),
            Text(
              l10n.milkStorageSafetyNote,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withAlpha(165),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            _label(l10n.labelNumber),
            TextField(
              controller: _labelController,
              textCapitalization: TextCapitalization.characters,
              decoration: _decoration(l10n.labelNumber),
            ),
            const SizedBox(height: 16),
            _label(l10n.amountMl),
            _amountSelector(),
            const SizedBox(height: 16),
            _label(l10n.storageLocation),
            _storageSelector(l10n),
            const SizedBox(height: 16),
            _label(l10n.expressedAt),
            _dateTimeTile(),
            const SizedBox(height: 16),
            _label(l10n.pumpedFrom),
            _sourceSelector(l10n),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.inventory_2_rounded),
                label: Text(
                  widget.existingBatch == null
                      ? l10n.saveMilk
                      : l10n.saveChanges,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xff6D63E8),
                  foregroundColor: Colors.white,
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

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _amountSelector() {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _amount,
            min: 10,
            max: 500,
            divisions: 49,
            onChanged: (value) {
              setState(() {
                _amount = value;
                _amountController.text = value.round().toString();
              });
            },
          ),
        ),
        SizedBox(
          width: 78,
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: _decoration('ml'),
            onChanged: (value) {
              final amount = double.tryParse(value);
              if (amount != null && amount >= 10 && amount <= 500) {
                setState(() => _amount = amount);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _storageSelector(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _selectionCard(
            icon: Icons.kitchen_rounded,
            label: l10n.refrigerator,
            selected: _location == MilkStorageLocation.refrigerator,
            onTap: () =>
                setState(() => _location = MilkStorageLocation.refrigerator),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _selectionCard(
            icon: Icons.ac_unit_rounded,
            label: l10n.freezer,
            selected: _location == MilkStorageLocation.freezer,
            onTap: () =>
                setState(() => _location = MilkStorageLocation.freezer),
          ),
        ),
      ],
    );
  }

  Widget _dateTimeTile() {
    final localizations = MaterialLocalizations.of(context);
    return ListTile(
      onTap: _pickDateTime,
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor.withAlpha(75)),
      ),
      leading: const Icon(
        Icons.calendar_month_rounded,
        color: Color(0xff6D63E8),
      ),
      title: Text(localizations.formatMediumDate(_expressedAt)),
      subtitle: Text(
        localizations.formatTimeOfDay(TimeOfDay.fromDateTime(_expressedAt)),
      ),
    );
  }

  Widget _sourceSelector(AppLocalizations l10n) {
    return DropdownButtonFormField<MilkSourceSide>(
      initialValue: _source,
      decoration: _decoration(l10n.pumpedFrom),
      items: [
        DropdownMenuItem(
          value: MilkSourceSide.unspecified,
          child: Text(l10n.unspecified),
        ),
        DropdownMenuItem(
          value: MilkSourceSide.left,
          child: Text(l10n.leftLabel),
        ),
        DropdownMenuItem(
          value: MilkSourceSide.right,
          child: Text(l10n.rightLabel),
        ),
        DropdownMenuItem(value: MilkSourceSide.mixed, child: Text(l10n.mixed)),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _source = value);
      },
    );
  }

  Widget _label(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).dividerColor.withAlpha(75),
        ),
      ),
    );
  }

  Widget _selectionCard({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xff6D63E8).withAlpha(18)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xff6D63E8)
                : Theme.of(context).dividerColor.withAlpha(75),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xff6D63E8)),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}
