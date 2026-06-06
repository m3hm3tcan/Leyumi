import 'package:flutter/material.dart';
import 'package:babyfeedpro/l10n/app_localizations.dart';
import '../../services/diaper_storage.dart';
import 'diaper_entry.dart';

class DiaperAddScreen extends StatefulWidget {
  const DiaperAddScreen({super.key});

  @override
  State<DiaperAddScreen> createState() => _DiaperAddScreenState();
}

class _DiaperAddScreenState extends State<DiaperAddScreen> {
  DiaperType type = DiaperType.pee;
  PeeAmount? peeAmount = PeeAmount.small;
  PoopColor? poopColor = PoopColor.brown;

  final noteCtrl = TextEditingController();

  Future<void> save() async {
    final entry = DiaperEntry(
      timestamp: DateTime.now(),
      type: type,
      peeAmount: type == DiaperType.pee || type == DiaperType.both
          ? peeAmount
          : null,
      poopColor: type == DiaperType.poop || type == DiaperType.both
          ? poopColor
          : null,
      note: noteCtrl.text.isEmpty ? null : noteCtrl.text,
    );

    await DiaperStorage().addEntry(entry);

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.diaperRecordSaved)),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: Text(l10n.diaperScreenTitle),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.diaperType,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: DiaperType.values.map((t) {
                      final selected = t == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => type = t),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected ? Colors.blue.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? Colors.blue : Colors.grey.shade200,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _labelForType(t, l10n),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.blue : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  if (type == DiaperType.pee || type == DiaperType.both) ...[
                    const SizedBox(height: 8),
                    Text(l10n.peeAmountTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: PeeAmount.values.map((p) {
                        final sel = p == peeAmount;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => peeAmount = p),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? Colors.green.shade50 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel ? Colors.green : Colors.grey.shade200,
                                ),
                              ),
                              child: Center(child: Text(_labelForPeeAmount(p, l10n))),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  if (type == DiaperType.poop || type == DiaperType.both) ...[
                    const SizedBox(height: 12),
                    Text(l10n.poopColor, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<PoopColor>(
                      value: poopColor,
                      items: PoopColor.values
                          .map((c) => DropdownMenuItem(value: c, child: Text(_labelForPoopColor(c, l10n))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => poopColor = v);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Text(l10n.note, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.optionalNote,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: save,
                child: Text(l10n.saveDiaperRecord, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelForType(DiaperType t, AppLocalizations l10n) {
    switch (t) {
      case DiaperType.pee:
        return l10n.pee;
      case DiaperType.poop:
        return l10n.poop;
      case DiaperType.both:
        return l10n.peeAndPoop;
    }
  }

  String _labelForPeeAmount(PeeAmount amount, AppLocalizations l10n) {
    switch (amount) {
      case PeeAmount.small:
        return l10n.small;
      case PeeAmount.medium:
        return l10n.medium;
      case PeeAmount.large:
        return l10n.large;
    }
  }

  String _labelForPoopColor(PoopColor color, AppLocalizations l10n) {
    switch (color) {
      case PoopColor.yellow:
        return l10n.yellow;
      case PoopColor.brown:
        return l10n.brown;
      case PoopColor.green:
        return l10n.green;
      case PoopColor.black:
        return l10n.black;
    }
  }
}
