import 'package:flutter/material.dart';
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diaper record saved')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text('Add Diaper'),
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
                  const Text(
                    'Diaper Type',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
                                t.name.toUpperCase(),
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
                    const Text('Pee Amount', style: TextStyle(fontWeight: FontWeight.w700)),
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
                              child: Center(child: Text(p.name.toUpperCase())),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  if (type == DiaperType.poop || type == DiaperType.both) ...[
                    const SizedBox(height: 12),
                    const Text('Poop Color', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<PoopColor>(
                      value: poopColor,
                      items: PoopColor.values
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                          .toList(),
                      onChanged: (v) => setState(() => poopColor = v),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Text('Note', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Optional note',
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
                child: const Text('Save Diaper Record', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
