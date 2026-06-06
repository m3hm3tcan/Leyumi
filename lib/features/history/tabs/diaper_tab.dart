import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:babyfeedpro/services/diaper_storage.dart';
import 'package:babyfeedpro/features/diaper/diaper_entry.dart';

class DiaperTab extends StatefulWidget {
  const DiaperTab({super.key});

  @override
  State<DiaperTab> createState() => _DiaperTabState();
}

class _DiaperTabState extends State<DiaperTab> {
  List<DiaperEntry> entries = [];
  bool loading = true;

  bool showTooltip = false;
  static const _tooltipKey = 'diaper_tab_open_count';
  DiaperEntry? recentlyDeleted;
  int? recentlyDeletedIndex;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _checkTooltip();
    await load();
  }

  Future<void> _checkTooltip() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_tooltipKey) ?? 0;
    if (count < 3) {
      setState(() => showTooltip = true);
      await prefs.setInt(_tooltipKey, count + 1);
    }
  }

  Future<void> load() async {
    final data = await DiaperStorage().loadEntries();
    setState(() {
      entries = data;
      loading = false;
    });
  }

  Future<void> deleteEntry(DiaperEntry entry) async {
    final index = entries.indexOf(entry);
    setState(() {
      recentlyDeleted = entry;
      recentlyDeletedIndex = index;
      entries.removeAt(index);
    });

    await DiaperStorage().saveAllEntries(entries.reversed.toList());

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final controller = messenger.showSnackBar(
      SnackBar(
        content: const Text('Entry deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () async {
            if (!mounted) return;
            if (recentlyDeleted != null && recentlyDeletedIndex != null) {
              setState(() {
                entries.insert(recentlyDeletedIndex!, recentlyDeleted!);
                recentlyDeleted = null;
                recentlyDeletedIndex = null;
              });
              await DiaperStorage().saveAllEntries(entries.reversed.toList());
            }
          },
        ),
      ),
    );

    controller.closed.then((reason) {
      if (reason != SnackBarClosedReason.action) {
        if (!mounted) return;
        setState(() {
          recentlyDeleted = null;
          recentlyDeletedIndex = null;
        });
      }
    });
  }

  Map<String, List<DiaperEntry>> group() {
    final Map<String, List<DiaperEntry>> map = {};
    for (final e in entries) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final day = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      final key = day == today ? 'Today' : 'Older';
      map.putIfAbsent(key, () => []);
      map[key]!.add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    final grouped = group();

    return Container(
      color: const Color(0xffF6F7FB),
      child: entries.isEmpty
          ? _emptyState()
          : ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SizedBox(height: 12),
                if (showTooltip) _swipeHint(),

                for (final section in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      section.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  ...section.value.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: _modernItem(e),
                      )),
                ],
              ],
            ),
    );
  }

  Widget _swipeHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => showTooltip = false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.swipe, color: Colors.blueAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Sola çekerek sil',
                        style: TextStyle(fontWeight: FontWeight.w700, decoration: TextDecoration.none),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'İlk 3 açılışta bu ipucu gösterilir.',
                        style: TextStyle(decoration: TextDecoration.none),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.close, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernItem(DiaperEntry e) {
    return Dismissible(
      key: ValueKey(e.timestamp.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => deleteEntry(e),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6))]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _bgForType(e.type), borderRadius: BorderRadius.circular(12)),
              child: _icon(e.type),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _titleFor(e),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (e.note != null && e.note!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                          child: const Text(
                            'Note',
                            style: TextStyle(fontSize: 11, decoration: TextDecoration.none),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _detailsFor(e),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${e.timestamp.hour.toString().padLeft(2, '0')}:${e.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            )
          ],
        ),
      ),
    );
  }

  Color _bgForType(DiaperType t) {
    switch (t) {
      case DiaperType.pee:
        return Colors.blue.withOpacity(0.12);
      case DiaperType.poop:
        return Colors.orange.withOpacity(0.12);
      case DiaperType.both:
        return Colors.purple.withOpacity(0.12);
    }
  }

  Widget _icon(DiaperType t) {
    switch (t) {
      case DiaperType.pee:
        return const Icon(Icons.invert_colors, color: Colors.blue);
      case DiaperType.poop:
        return const Icon(Icons.grass, color: Colors.orange);
      case DiaperType.both:
        return const Icon(Icons.bubble_chart, color: Colors.purple);
    }
  }

  String _titleFor(DiaperEntry e) {
    switch (e.type) {
      case DiaperType.pee:
        return 'Pee';
      case DiaperType.poop:
        return 'Poop';
      case DiaperType.both:
        return 'Pee & Poop';
    }
  }

  String _detailsFor(DiaperEntry e) {
    final parts = <String>[];
    if (e.peeAmount != null) parts.add('Amount: ${e.peeAmount!.name}');
    if (e.poopColor != null) parts.add('Color: ${e.poopColor!.name}');
    if (e.note != null && e.note!.isNotEmpty) parts.add('"${e.note!}"');
    return parts.join(' • ');
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 8))]),
              child: const Icon(Icons.baby_changing_station, size: 60, color: Colors.blueGrey),
            ),
            const SizedBox(height: 18),
            const Text(
              'No diaper records yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add diaper changes from the home screen to track history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                decoration: TextDecoration.none,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
