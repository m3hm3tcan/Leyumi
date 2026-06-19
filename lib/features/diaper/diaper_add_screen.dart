import 'package:flutter/material.dart';
import 'package:babyfeedpro/l10n/app_localizations.dart';
import '../../services/diaper_storage.dart';
import 'diaper_entry.dart';
import 'package:provider/provider.dart';
import 'package:babyfeedpro/core/theme_provider.dart';

class DiaperAddScreen extends StatefulWidget {
  const DiaperAddScreen({super.key});

  @override
  State<DiaperAddScreen> createState() => _DiaperAddScreenState();
}

class _DiaperAddScreenState extends State<DiaperAddScreen> {
  DiaperType type = DiaperType.pee;
  PeeAmount? peeAmount = PeeAmount.medium;
  PoopColor? poopColor = PoopColor.mustardYellow;
  DateTime selectedDateTime = DateTime.now();

  final noteCtrl = TextEditingController();

  Future<void> save() async {
    final entry = DiaperEntry(
      timestamp: selectedDateTime,
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

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ),
      lastDate: DateTime.now(),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        selectedDateTime,
      ),
    );

    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.diaperScreenTitle),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // DATE & TIME CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dateAndTime,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: pickDateTime,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule),
                          const SizedBox(width: 10),
                          Text(
                            "${selectedDateTime.day}.${selectedDateTime.month}.${selectedDateTime.year}"
                            "  ${selectedDateTime.hour.toString().padLeft(2, '0')}:"
                            "${selectedDateTime.minute.toString().padLeft(2, '0')}",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // DIAPER TYPE
            Text(l10n.diaperType, style: const TextStyle(fontWeight: FontWeight.w700)),
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
                        color: selected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? Colors.blue : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_emojiForType(t), style: const TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              _labelForType(t, l10n),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // PEE AMOUNT
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
                          color: sel
                            ? Colors.green.withOpacity(0.15)
                            : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel ? Colors.green : Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Center(child: Text(_labelForPeeAmount(p, l10n))),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // POOP COLOR
            if (type == DiaperType.poop || type == DiaperType.both) ...[
              const SizedBox(height: 12),
              Text(l10n.poopColor, style: const TextStyle(fontWeight: FontWeight.w700)),

              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.8,
                children: PoopColor.values.map((color) {
                  final selected = poopColor == color;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        poopColor = color;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.blue.shade50
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? Colors.blue
                              : Theme.of(context).dividerColor,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 18,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _colorForPoop(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              _labelForPoopColor(color, l10n),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          if (selected)
                             Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 10),

            // NOTE
            Text(l10n.note, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.optionalNote,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: save,
                child: Text(
                  l10n.saveDiaperRecord,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
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

  // String _labelForPoopColor(PoopColor color, AppLocalizations l10n) {
  //   switch (color) {
  //     case PoopColor.yellow:
  //       return l10n.yellow;
  //     case PoopColor.brown:
  //       return l10n.brown;
  //     case PoopColor.green:
  //       return l10n.green;
  //     case PoopColor.black:
  //       return l10n.black;
  //   }
  // }

  String _labelForPoopColor(
    PoopColor color,
    AppLocalizations l10n,
  ) {
    switch (color) {
      case PoopColor.mustardYellow:
        return  l10n.mustardYellow;

      case PoopColor.yellowGreen:
        return l10n.yellowGreen;

      case PoopColor.brown:
        return l10n.brown;

      case PoopColor.darkGreen:
        return l10n.darkGreen;

      case PoopColor.black:
        return l10n.black;

      case PoopColor.whiteGray:
        return l10n.whiteGray;
    }
  }

  Color _colorForPoop(PoopColor color) {
    switch (color) {
      case PoopColor.mustardYellow:
        return const Color(0xffD4B233);

      case PoopColor.yellowGreen:
        return const Color(0xff9EBB3D);

      case PoopColor.brown:
        return const Color(0xff8D5A2B);

      case PoopColor.darkGreen:
        return const Color(0xff3F6B3F);

      case PoopColor.black:
        return Colors.black;

      case PoopColor.whiteGray:
        return const Color(0xffD8D8D8);
    }
  }

   String _emojiForType(DiaperType type) {
    switch (type) {
      case DiaperType.pee:
        return "💦";

      case DiaperType.poop:
        return "💩";

      case DiaperType.both:
        return "💦💩";
    }
  }

}

 