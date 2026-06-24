import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/record_identity.dart';
import '../../core/premium/premium_feature.dart';
import '../../core/premium/premium_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/baby_storage.dart';
import '../premium/premium_paywall_screen.dart';
import 'dialogs/milk_inventory_dialogs.dart';
import 'milk_batch.dart';
import 'milk_inventory_controller.dart';
import 'sheets/add_milk_batch_sheet.dart';
import 'widgets/milk_batch_card.dart';
import 'widgets/milk_inventory_empty_state.dart';
import 'widgets/milk_inventory_filter_bar.dart';
import 'widgets/milk_inventory_summary_card.dart';

class MilkInventoryScreen extends StatefulWidget {
  const MilkInventoryScreen({super.key});

  @override
  State<MilkInventoryScreen> createState() => _MilkInventoryScreenState();
}

class _MilkInventoryScreenState extends State<MilkInventoryScreen> {
  late final MilkInventoryController _controller;
  String _childId = RecordIdentity.legacyChildId;

  @override
  void initState() {
    super.initState();
    _controller = MilkInventoryController()..addListener(_onChanged);
    _load();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    _childId =
        (await BabyStorage().loadProfile())?.id ?? RecordIdentity.legacyChildId;
    await _controller.load();
  }

  Future<void> _addMilk() async {
    final batch = await _openMilkSheet(
      suggestedLabel: _controller.nextLabel(),
      childId: _childId,
      existingLabels: _controller.batches
          .map((batch) => batch.labelNumber)
          .toSet(),
    );
    if (batch != null) await _controller.add(batch);
  }

  Future<void> _editMilk(MilkBatch batch) async {
    final updated = await _openMilkSheet(
      suggestedLabel: batch.labelNumber,
      childId: batch.childId,
      existingLabels: _controller.batches
          .where((item) => item.id != batch.id)
          .map((item) => item.labelNumber)
          .toSet(),
      existingBatch: batch,
    );
    if (updated != null) await _controller.update(batch, updated);
  }

  Future<MilkBatch?> _openMilkSheet({
    required String suggestedLabel,
    required String childId,
    required Set<String> existingLabels,
    MilkBatch? existingBatch,
  }) {
    return showModalBottomSheet<MilkBatch>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMilkBatchSheet(
        suggestedLabel: suggestedLabel,
        childId: childId,
        existingLabels: existingLabels,
        existingBatch: existingBatch,
      ),
    );
  }

  Future<void> _delete(MilkBatch batch) async {
    if (!await showDeleteMilkDialog(context)) return;
    await _controller.deleteIncorrect(batch);
  }

  Future<void> _useMilk(MilkBatch batch) async {
    final amount = await showMilkAmountDialog(
      context,
      batch: batch,
      title: AppLocalizations.of(context).useMilk,
    );
    if (amount != null) await _controller.use(batch, amount);
  }

  Future<void> _discardMilk(MilkBatch batch) async {
    final amount = await showMilkAmountDialog(
      context,
      batch: batch,
      title: AppLocalizations.of(context).discardMilk,
      destructive: true,
    );
    if (amount != null) await _controller.discard(batch, amount);
  }

  Future<void> _moveStorage(MilkBatch batch) async {
    if (batch.storageLocation == MilkStorageLocation.refrigerator) {
      await _controller.moveToFreezer(batch);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final premium = context.watch<PremiumProvider>();

    if (!premium.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!premium.hasAccess(PremiumFeature.milkInventory)) {
      return const PremiumPaywallScreen(feature: PremiumFeature.milkInventory);
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
      body: _controller.loading
          ? const Center(child: CircularProgressIndicator())
          : _inventoryContent(),
    );
  }

  Widget _inventoryContent() {
    final visibleBatches = _controller.visibleBatches;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          sliver: SliverToBoxAdapter(child: _summaryCard()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          sliver: SliverToBoxAdapter(
            child: MilkInventoryFilterBar(
              value: _controller.filter,
              onChanged: _controller.setFilter,
            ),
          ),
        ),
        if (visibleBatches.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: MilkInventoryEmptyState(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
            sliver: SliverList.separated(
              itemCount: visibleBatches.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final batch = visibleBatches[index];
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
    );
  }

  Widget _summaryCard() {
    return MilkInventorySummaryCard(
      totalMl: _controller.totalMl,
      activeBottleCount: _controller.batches
          .where((batch) => batch.isActive)
          .length,
      refrigeratorMl: _controller.locationTotal(
        MilkStorageLocation.refrigerator,
      ),
      freezerMl: _controller.locationTotal(MilkStorageLocation.freezer),
      leftMl: _controller.sourceTotal(MilkSourceSide.left),
      rightMl: _controller.sourceTotal(MilkSourceSide.right),
      mixedMl: _controller.sourceTotal(MilkSourceSide.mixed),
      showSourceStats: _controller.hasSourceStats,
    );
  }
}
