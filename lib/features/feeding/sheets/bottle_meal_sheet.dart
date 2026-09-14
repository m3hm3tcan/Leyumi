import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/premium/premium_feature.dart';
import '../../../core/premium/premium_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/baby_storage.dart';
import '../../../services/feeding_storage.dart';
import '../../../services/milk_inventory_storage.dart';
import '../../milk_inventory/milk_batch.dart';
import '../bottle_portion.dart';
import '../feeding_session.dart';

class BottleMealSheet extends StatefulWidget {
  const BottleMealSheet({
    super.key,
    this.meal,
    this.initialMilk = BottleMilk.formula,
  });
  final FeedingSession? meal;
  final BottleMilk initialMilk;

  @override
  State<BottleMealSheet> createState() => _BottleMealSheetState();
}

class _PortionDraft {
  _PortionDraft(BottlePortion portion)
    : id = portion.id,
      milk = portion.milk,
      batchId = portion.batchId,
      amount = TextEditingController(
        text: portion.amountMl > 0 ? '${portion.amountMl}' : '',
      );
  final String id;
  BottleMilk milk;
  String? batchId;
  bool useStock = false;
  final TextEditingController amount;
}

class _BottleMealSheetState extends State<BottleMealSheet> {
  final _form = GlobalKey<FormState>();
  final _note = TextEditingController();
  final _portions = <_PortionDraft>[];
  List<MilkBatch> _batches = [];
  FeedingSession? _meal;
  bool _saving = false;
  bool _loadingStock = false;
  bool _initialStockRequested = false;
  String? _error;
  late DateTime _time;

  @override
  void initState() {
    super.initState();
    _time = widget.meal?.startTime ?? DateTime.now();
    _meal = widget.meal;
    _note.text = widget.meal?.note ?? '';
    for (final portion in widget.meal?.bottles ?? <BottlePortion>[]) {
      _portions.add(_PortionDraft(portion)..useStock = portion.batchId != null);
    }
    if (_portions.isEmpty) _add(widget.initialMilk);
    _initialize();
  }

  Future<void> _initialize() async {
    if (widget.meal != null) return;
    try {
      final profile = await BabyStorage().loadProfile();
      if (!mounted) return;
      _meal =
          widget.meal ??
          FeedingSession(
            childId: profile!.id,
            startTime: _time,
            endTime: _time,
            entries: [],
          );
      if (widget.meal == null) {
        final previous = await FeedingStorage().loadSessions();
        previous.sort((a, b) => b.startTime.compareTo(a.startTime));
        final last = previous
            .expand((m) => m.bottles)
            .where((b) => b.milk == widget.initialMilk)
            .firstOrNull;
        if (mounted && last != null && _portions.first.amount.text.isEmpty) {
          _portions.first.amount.text = '${last.amountMl}';
        }
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).operationFailed);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final premium = context.watch<PremiumProvider>().hasAccess(
      PremiumFeature.milkInventory,
    );
    if (premium &&
        !_initialStockRequested &&
        _portions.any((p) => p.useStock)) {
      _initialStockRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadStock();
      });
    }
  }

  void _add(BottleMilk milk) {
    _portions.add(_PortionDraft(BottlePortion(milk: milk, amountMl: 0)));
  }

  @override
  void dispose() {
    for (final portion in _portions) {
      portion.amount.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  Future<void> _loadStock() async {
    if (!context.read<PremiumProvider>().hasAccess(
      PremiumFeature.milkInventory,
    )) {
      return;
    }
    setState(() => _loadingStock = true);
    try {
      final batches = await MilkInventoryStorage().loadBatches();
      if (mounted) {
        setState(() {
          _batches =
              batches
                  .where(
                    (b) =>
                        b.childId == _meal?.childId &&
                        b.isActive &&
                        !b.isExpired &&
                        !b.expressedAt.isAfter(_time),
                  )
                  .toList()
                ..sort((a, b) => a.bestBefore.compareTo(b.bestBefore));
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).operationFailed);
      }
    } finally {
      if (mounted) setState(() => _loadingStock = false);
    }
  }

  Future<void> _pickTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _time,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_time),
    );
    if (time == null || !mounted) return;
    setState(() {
      _time = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_saving || _meal == null || !_form.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    if (_time
        .add(_meal!.endTime.difference(_meal!.startTime))
        .isAfter(DateTime.now())) {
      setState(() => _error = l10n.futureDateTimeError);
      return;
    }
    final premium = context.read<PremiumProvider>().hasAccess(
      PremiumFeature.milkInventory,
    );
    final bottles = <BottlePortion>[];
    for (final draft in _portions) {
      final existing = widget.meal?.bottles
          .where((b) => b.id == draft.id)
          .firstOrNull;
      // If entitlement changes while the form is open, don't create a hidden link.
      final batchId = premium
          ? (draft.useStock ? draft.batchId : null)
          : existing?.batchId;
      if (premium && draft.useStock && batchId == null) {
        setState(() => _error = l10n.feedingStockError);
        return;
      }
      bottles.add(
        BottlePortion(
          id: draft.id,
          milk: draft.milk,
          amountMl: int.parse(draft.amount.text),
          batchId: batchId,
        ),
      );
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final meal = _meal!.withBottles(
        bottles,
        note: _note.text.trim(),
        time: _time,
      );
      await FeedingStorage().saveMeal(meal, inventoryAccess: premium);
      if (mounted) Navigator.pop(context, meal);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.feedingStockError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final premium = context.watch<PremiumProvider>().hasAccess(
      PremiumFeature.milkInventory,
    );
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_saving,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: AbsorbPointer(
            absorbing: _saving,
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.feeding,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule),
                    title: Text(l10n.feedingMealTime),
                    subtitle: Text(
                      '${MaterialLocalizations.of(context).formatMediumDate(_time)} · ${TimeOfDay.fromDateTime(_time).format(context)}',
                    ),
                    onTap: _pickTime,
                  ),
                  if (_meal?.hasBreastfeeding ?? false)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.favorite_outline),
                        title: Text(l10n.feedingBreast),
                        subtitle: Text(
                          '${_meal!.totalDuration.inMinutes} ${l10n.minutesShort}',
                        ),
                      ),
                    ),
                  for (final portion in _portions)
                    _portionCard(portion, l10n, premium),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final milk in BottleMilk.values)
                        TextButton.icon(
                          onPressed: () => setState(() => _add(milk)),
                          icon: const Icon(Icons.add),
                          label: Text(
                            milk == BottleMilk.formula
                                ? l10n.feedingFormula
                                : l10n.feedingExpressed,
                          ),
                        ),
                    ],
                  ),
                  TextFormField(
                    controller: _note,
                    maxLength: 500,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.feedingNote),
                  ),
                  if (widget.meal?.bottles.any((b) => b.batchId != null) ??
                      false)
                    Text(
                      l10n.feedingStockCorrection,
                      style: theme.textTheme.bodySmall,
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving || _meal == null ? null : _save,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(_saving ? l10n.saving : l10n.feedingSaveMeal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _portionCard(
    _PortionDraft portion,
    AppLocalizations l10n,
    bool premium,
  ) {
    final linked = widget.meal?.bottles
        .where((b) => b.id == portion.id)
        .firstOrNull
        ?.batchId;
    return Card(
      key: ValueKey(portion.id),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    portion.milk == BottleMilk.formula
                        ? l10n.feedingFormula
                        : l10n.feedingExpressed,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (_portions.length > 1 || (_meal?.hasBreastfeeding ?? false))
                  IconButton(
                    tooltip: l10n.feedingRemove,
                    onPressed: () {
                      setState(() => _portions.remove(portion));
                      // Controller disposal is deferred until its field leaves the tree.
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => portion.amount.dispose(),
                      );
                    },
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            TextFormField(
              controller: portion.amount,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
              decoration: InputDecoration(
                labelText: l10n.feedingConsumed,
                suffixText: 'ml',
              ),
              validator: (value) => (int.tryParse(value ?? '') ?? 0) > 0
                  ? null
                  : l10n.feedingAmountError,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final amount in [30, 60, 90, 120, 150])
                  ActionChip(
                    label: Text('$amount ml'),
                    onPressed: () => portion.amount.text = '$amount',
                  ),
              ],
            ),
            if (premium && portion.milk == BottleMilk.expressed) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.feedingUseStock),
                value: portion.useStock,
                onChanged: _loadingStock
                    ? null
                    : (value) async {
                        setState(() {
                          portion.useStock = value;
                          if (!value) portion.batchId = null;
                        });
                        if (value) await _loadStock();
                      },
              ),
              if (portion.useStock) ...[
                if (_loadingStock) const LinearProgressIndicator(),
                DropdownButtonFormField<String>(
                  key: ValueKey(
                    '${portion.id}-${portion.batchId}-${_batches.length}',
                  ),
                  initialValue: portion.batchId,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.feedingBatch),
                  items: [
                    if (portion.batchId != null &&
                        !_batches.any((b) => b.id == portion.batchId))
                      DropdownMenuItem(
                        value: portion.batchId,
                        child: Text(l10n.feedingBatch),
                      ),
                    for (final batch in _batches)
                      DropdownMenuItem(
                        value: batch.id,
                        child: Text(
                          '${batch.labelNumber} · ${batch.remainingAmountMl} ml',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => portion.batchId = value),
                ),
                if (_batches.isEmpty && linked == null && !_loadingStock)
                  Text(l10n.feedingNoStock),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
