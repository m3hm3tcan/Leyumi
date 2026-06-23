import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:leyumi/core/premium/premium_feature.dart';
import 'package:leyumi/core/premium/premium_provider.dart';
import 'package:leyumi/features/milk_inventory/milk_batch.dart';
import 'package:leyumi/features/premium/premium_paywall_screen.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:leyumi/services/milk_inventory_storage.dart';
import 'package:provider/provider.dart';

class MilkInventoryScreen extends StatefulWidget {
  const MilkInventoryScreen({super.key});

  @override
  State<MilkInventoryScreen> createState() => _MilkInventoryScreenState();
}

class _MilkInventoryScreenState extends State<MilkInventoryScreen> {
  final _storage = MilkInventoryStorage();
  List<MilkBatch> _batches = [];
  MilkStorageLocation? _filter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final batches = await _storage.loadBatches();
    batches.sort((a, b) => a.bestBefore.compareTo(b.bestBefore));
    if (!mounted) return;
    setState(() {
      _batches = batches;
      _loading = false;
    });
  }

  List<MilkBatch> get _visibleBatches {
    if (_filter == null) {
      return _batches.where((batch) => batch.isActive).toList();
    }
    return _batches
        .where(
          (batch) => batch.isActive && batch.storageLocation == _filter,
        )
        .toList();
  }

  int get _totalMl => _batches
      .where((batch) => batch.isActive)
      .fold(0, (total, batch) => total + batch.remainingAmountMl);

  int _locationTotal(MilkStorageLocation location) {
    return _batches
        .where(
          (batch) =>
              batch.isActive && batch.storageLocation == location,
        )
        .fold(0, (total, batch) => total + batch.remainingAmountMl);
  }

  int _sourceTotal(MilkSourceSide source) {
    return _batches
        .where(
          (batch) => batch.isActive && batch.sourceSide == source,
        )
        .fold(0, (total, batch) => total + batch.remainingAmountMl);
  }

  bool get _hasSourceStats => _batches.any(
        (batch) =>
            batch.isActive &&
            batch.sourceSide != MilkSourceSide.unspecified,
      );

  Future<void> _addMilk() async {
    final batch = await showModalBottomSheet<MilkBatch>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMilkBatchSheet(
        suggestedLabel: _nextLabel(),
        existingLabels: _batches.map((batch) => batch.labelNumber).toSet(),
      ),
    );

    if (batch == null) return;
    await _storage.addBatch(batch);
    await _load();
  }

  String _nextLabel() {
    var highest = 0;
    final pattern = RegExp(r'(\d+)$');
    for (final batch in _batches) {
      final match = pattern.firstMatch(batch.labelNumber);
      final value = match == null ? null : int.tryParse(match.group(1)!);
      if (value != null && value > highest) highest = value;
    }
    return 'MILK-${(highest + 1).toString().padLeft(3, '0')}';
  }

  Future<void> _delete(MilkBatch batch) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteMilkTitle),
        content: Text(l10n.deleteMilkContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _storage.deleteIncorrectBatch(batch.id);
    await _load();
  }

  Future<void> _useMilk(MilkBatch batch) async {
    final used = await _selectAmount(
      batch: batch,
      title: AppLocalizations.of(context).useMilk,
    );
    if (used == null) return;
    await _storage.useMilk(batch: batch, amountMl: used);
    await _load();
  }

  Future<void> _discardMilk(MilkBatch batch) async {
    final discarded = await _selectAmount(
      batch: batch,
      title: AppLocalizations.of(context).discardMilk,
      destructive: true,
    );
    if (discarded == null) return;
    await _storage.discardMilk(batch: batch, amountMl: discarded);
    await _load();
  }

  Future<int?> _selectAmount({
    required MilkBatch batch,
    required String title,
    bool destructive = false,
  }) {
    final l10n = AppLocalizations.of(context);
    var amount = batch.remainingAmountMl.toDouble();
    return showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${amount.round()} ml',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (batch.remainingAmountMl > 1)
                  Slider(
                    value: amount,
                    min: 1,
                    max: batch.remainingAmountMl.toDouble(),
                    divisions: batch.remainingAmountMl - 1,
                    onChanged: (value) =>
                        setDialogState(() => amount = value),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, amount.round()),
                style: destructive
                    ? FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      )
                    : null,
                child: Text(l10n.confirm),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editMilk(MilkBatch batch) async {
    final updated = await showModalBottomSheet<MilkBatch>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMilkBatchSheet(
        suggestedLabel: batch.labelNumber,
        existingLabels: _batches
            .where((item) => item.id != batch.id)
            .map((item) => item.labelNumber)
            .toSet(),
        existingBatch: batch,
      ),
    );
    if (updated == null) return;
    await _storage.updateBatch(previous: batch, updated: updated);
    await _load();
  }

  Future<void> _moveStorage(MilkBatch batch) async {
    if (batch.storageLocation != MilkStorageLocation.refrigerator) return;
    await _storage.moveToFreezer(batch);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final premium = context.watch<PremiumProvider>();

    if (!premium.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!premium.hasAccess(PremiumFeature.milkInventory)) {
      return const PremiumPaywallScreen(
        feature: PremiumFeature.milkInventory,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.milkInventory),
        actions: [
          IconButton(
            onPressed: _addMilk,
            icon: const Icon(Icons.add_rounded),
            tooltip: l10n.addMilk,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMilk,
        backgroundColor: const Color(0xff6D63E8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addMilk),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  sliver: SliverToBoxAdapter(child: _summaryCard(l10n)),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  sliver: SliverToBoxAdapter(child: _filterBar(l10n)),
                ),
                if (_visibleBatches.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _emptyState(l10n),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                    sliver: SliverList.separated(
                      itemCount: _visibleBatches.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final batch = _visibleBatches[index];
                        return MilkBatchCard(
                          key: ValueKey(batch.id),
                          batch: batch,
                          onUse: () => _useMilk(batch),
                          onDiscard: () => _discardMilk(batch),
                          onEdit: () => _editMilk(batch),
                          onDelete: () => _delete(batch),
                          onMove: () => _moveStorage(batch),
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _summaryCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff6257D9), Color(0xff9A67DC)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff6257D9).withAlpha(55),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.totalMilkStock.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withAlpha(180),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$_totalMl ml',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _summaryMetric(
                  Icons.kitchen_rounded,
                  l10n.refrigerator,
                  '${_locationTotal(MilkStorageLocation.refrigerator)} ml',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryMetric(
                  Icons.ac_unit_rounded,
                  l10n.freezer,
                  '${_locationTotal(MilkStorageLocation.freezer)} ml',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryMetric(
                  Icons.inventory_2_rounded,
                  l10n.bottles,
                  '${_batches.where((batch) => batch.isActive).length}',
                ),
              ),
            ],
          ),
          if (_hasSourceStats) ...[
            const SizedBox(height: 16),
            Container(height: 1, color: Colors.white.withAlpha(35)),
            const SizedBox(height: 13),
            Text(
              l10n.pumpedFrom,
              style: TextStyle(
                color: Colors.white.withAlpha(175),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _sourceMetric(
                    l10n.leftLabel,
                    _sourceTotal(MilkSourceSide.left),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _sourceMetric(
                    l10n.rightLabel,
                    _sourceTotal(MilkSourceSide.right),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _sourceMetric(
                    l10n.mixed,
                    _sourceTotal(MilkSourceSide.mixed),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryMetric(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(175),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sourceMetric(String label, int amount) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label · $amount ml',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterBar(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: _filterChip(l10n.all, null)),
        const SizedBox(width: 8),
        Expanded(
          child: _filterChip(
            l10n.refrigerator,
            MilkStorageLocation.refrigerator,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _filterChip(l10n.freezer, MilkStorageLocation.freezer),
        ),
      ],
    );
  }

  Widget _filterChip(String label, MilkStorageLocation? value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xff6D63E8)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xff6D63E8)
                : Theme.of(context).dividerColor.withAlpha(75),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? Colors.white : null,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _emptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xff6D63E8).withAlpha(18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_drink_rounded,
                color: Color(0xff6D63E8),
                size: 44,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.noStoredMilk,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              l10n.noStoredMilkHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    Theme.of(context).textTheme.bodySmall?.color?.withAlpha(165),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MilkBatchCard extends StatelessWidget {
  const MilkBatchCard({
    super.key,
    required this.batch,
    required this.onUse,
    required this.onDiscard,
    required this.onEdit,
    required this.onDelete,
    required this.onMove,
  });

  final MilkBatch batch;
  final VoidCallback onUse;
  final VoidCallback onDiscard;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final freshness = _freshness(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: freshness.color.withAlpha(45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(
              theme.brightness == Brightness.dark ? 32 : 10,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: batch.fillRatio),
            duration: const Duration(milliseconds: 850),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return SizedBox(
                width: 74,
                height: 128,
                child: CustomPaint(
                  painter: MilkBottlePainter(fillRatio: value),
                ),
              );
            },
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        batch.labelNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'move') onMove();
                        if (value == 'edit') onEdit();
                        if (value == 'discard') onDiscard();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        if (batch.storageLocation ==
                            MilkStorageLocation.refrigerator)
                          PopupMenuItem(
                            value: 'move',
                            child: Text(l10n.moveToFreezer),
                          ),
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(l10n.editMilkRecord),
                        ),
                        PopupMenuItem(
                          value: 'discard',
                          child: Text(l10n.discardMilk),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.deleteIncorrectRecord),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${batch.remainingAmountMl} / 500 ml',
                  style: const TextStyle(
                    color: Color(0xff6D63E8),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _chip(
                      batch.storageLocation ==
                              MilkStorageLocation.refrigerator
                          ? Icons.kitchen_rounded
                          : Icons.ac_unit_rounded,
                      batch.storageLocation ==
                              MilkStorageLocation.refrigerator
                          ? l10n.refrigerator
                          : l10n.freezer,
                    ),
                    _chip(
                      Icons.favorite_outline_rounded,
                      _sourceLabel(l10n),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.expressedAt}: ${_expressedLabel(context)}',
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(155),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: freshness.color,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        freshness.label,
                        style: TextStyle(
                          color: freshness.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onUse,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff6D63E8),
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(l10n.useMilk),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xff6D63E8).withAlpha(15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xff6D63E8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  String _sourceLabel(AppLocalizations l10n) {
    switch (batch.sourceSide) {
      case MilkSourceSide.left:
        return l10n.leftLabel;
      case MilkSourceSide.right:
        return l10n.rightLabel;
      case MilkSourceSide.mixed:
        return l10n.mixed;
      case MilkSourceSide.unspecified:
        return l10n.unspecified;
    }
  }

  String _expressedLabel(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return '${localizations.formatShortDate(batch.expressedAt)} · '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(batch.expressedAt))}';
  }

  ({String label, Color color}) _freshness(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remaining = batch.bestBefore.difference(DateTime.now());
    if (remaining.isNegative) {
      return (
        label:
            '${l10n.expired} · ${_bestBeforeLabel(context)}',
        color: Colors.redAccent,
      );
    }

    if (remaining.inHours < 24) {
      return (
        label:
            '${l10n.useWithin} ${remaining.inHours + 1} ${l10n.hoursShort} · ${_bestBeforeLabel(context)}',
        color: Colors.orange,
      );
    }

    if (remaining.inDays < 7) {
      return (
        label:
            '${l10n.freshFor} ${remaining.inDays + 1} ${l10n.daysShort} · ${_bestBeforeLabel(context)}',
        color: remaining.inDays <= 1 ? Colors.orange : Colors.green,
      );
    }

    final months = (remaining.inDays / 30).ceil();
    return (
      label:
          '${l10n.freshFor} $months ${l10n.monthsShort} · ${_bestBeforeLabel(context)}',
      color: Colors.green,
    );
  }

  String _bestBeforeLabel(BuildContext context) {
    return '${AppLocalizations.of(context).bestBefore}: '
        '${MaterialLocalizations.of(context).formatShortDate(batch.bestBefore)}';
  }
}

class MilkBottlePainter extends CustomPainter {
  MilkBottlePainter({required this.fillRatio});

  final double fillRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = const Color(0xffBBB7D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final cap = Paint()..color = const Color(0xff756CE8);
    final milk = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xffFFFEF2), Color(0xffF4EBCB)],
      ).createShader(Offset.zero & size);

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 23, size.width - 16, size.height - 29),
      const Radius.circular(15),
    );
    final neck = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 11, size.width - 40, 20),
      const Radius.circular(6),
    );
    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(17, 2, size.width - 34, 14),
      const Radius.circular(5),
    );

    canvas.drawRRect(capRect, cap);
    canvas.drawRRect(neck, outline);
    canvas.drawRRect(body, outline);

    final inner = body.deflate(4);
    final milkHeight = inner.height * fillRatio;
    final milkRect = Rect.fromLTWH(
      inner.left,
      inner.bottom - milkHeight,
      inner.width,
      milkHeight,
    );

    canvas.save();
    canvas.clipRRect(inner);
    canvas.drawRect(milkRect, milk);

    if (milkHeight > 2) {
      final wave = Path()..moveTo(inner.left, milkRect.top + 2);
      for (double x = inner.left; x <= inner.right; x += 2) {
        final y = milkRect.top + math.sin(x / 6) * 1.8;
        wave.lineTo(x, y);
      }
      wave
        ..lineTo(inner.right, milkRect.top + 5)
        ..lineTo(inner.left, milkRect.top + 5)
        ..close();
      canvas.drawPath(wave, milk);
    }
    canvas.restore();

    final marker = Paint()
      ..color = const Color(0xffBBB7D8).withAlpha(130)
      ..strokeWidth = 1;
    for (var i = 1; i < 5; i++) {
      final y = inner.bottom - inner.height * i / 5;
      canvas.drawLine(
        Offset(inner.right - 10, y),
        Offset(inner.right, y),
        marker,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MilkBottlePainter oldDelegate) {
    return oldDelegate.fillRatio != fillRatio;
  }
}

class AddMilkBatchSheet extends StatefulWidget {
  const AddMilkBatchSheet({
    super.key,
    required this.suggestedLabel,
    required this.existingLabels,
    this.existingBatch,
  });

  final String suggestedLabel;
  final Set<String> existingLabels;
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
    _location =
        existing?.storageLocation ?? MilkStorageLocation.refrigerator;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidMilkEntry)),
      );
      return;
    }
    if (widget.existingLabels.any(
      (existing) => existing.toLowerCase() == label.toLowerCase(),
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.duplicateMilkLabel)),
      );
      return;
    }

    Navigator.pop(
      context,
      widget.existingBatch == null
          ? MilkBatch(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              labelNumber: label,
              initialAmountMl: amount,
              remainingAmountMl: amount,
              expressedAt: _expressedAt,
              storageLocation: _location,
              sourceSide: _source,
              createdAt: DateTime.now(),
            )
          : widget.existingBatch!.copyWith(
              labelNumber: label,
              initialAmountMl: math.max(
                widget.existingBatch!.initialAmountMl,
                amount,
              ).toInt(),
              remainingAmountMl: amount,
              expressedAt: _expressedAt,
              storageLocation: _location,
              sourceSide: _source,
              status: MilkBatchStatus.active,
              frozenAt: _location == MilkStorageLocation.freezer
                  ? widget.existingBatch!.frozenAt
                  : null,
              clearFrozenAt: _location == MilkStorageLocation.refrigerator,
            ),
    );
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
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          24 + media.viewInsets.bottom,
        ),
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
              widget.existingBatch == null
                  ? l10n.addMilk
                  : l10n.editMilkRecord,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              l10n.milkStorageSafetyNote,
              style: TextStyle(
                color:
                    Theme.of(context).textTheme.bodySmall?.color?.withAlpha(165),
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
            Row(
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
            ),
            const SizedBox(height: 16),
            _label(l10n.storageLocation),
            Row(
              children: [
                Expanded(
                  child: _selectionCard(
                    icon: Icons.kitchen_rounded,
                    label: l10n.refrigerator,
                    selected: _location == MilkStorageLocation.refrigerator,
                    onTap: () => setState(
                      () => _location = MilkStorageLocation.refrigerator,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _selectionCard(
                    icon: Icons.ac_unit_rounded,
                    label: l10n.freezer,
                    selected: _location == MilkStorageLocation.freezer,
                    onTap: () => setState(
                      () => _location = MilkStorageLocation.freezer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label(l10n.expressedAt),
            ListTile(
              onTap: _pickDateTime,
              tileColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withAlpha(75),
                ),
              ),
              leading: const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xff6D63E8),
              ),
              title: Text(
                MaterialLocalizations.of(context)
                    .formatMediumDate(_expressedAt),
              ),
              subtitle: Text(
                MaterialLocalizations.of(context).formatTimeOfDay(
                  TimeOfDay.fromDateTime(_expressedAt),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _label(l10n.pumpedFrom),
            DropdownButtonFormField<MilkSourceSide>(
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
                DropdownMenuItem(
                  value: MilkSourceSide.mixed,
                  child: Text(l10n.mixed),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _source = value);
              },
            ),
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
