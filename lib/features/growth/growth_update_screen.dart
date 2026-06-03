import 'package:flutter/material.dart';
import '../../models/baby_profile.dart';
import '../../models/growth_entry.dart';
import '../../services/baby_storage.dart';
import '../../services/growth_storage.dart';

class GrowthUpdateScreen extends StatefulWidget {
  const GrowthUpdateScreen({super.key});

  @override
  State<GrowthUpdateScreen> createState() => _GrowthUpdateScreenState();
}

class _GrowthUpdateScreenState extends State<GrowthUpdateScreen> {
  BabyProfile? profile;

  final weightCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  final headCtrl = TextEditingController();
  final waistCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final p = await BabyStorage().loadProfile();
    setState(() => profile = p);
  }

  void save() async {
    if (profile == null) return;

    final entry = GrowthEntry(
        date: DateTime.now(),
        weight: int.parse(weightCtrl.text), // GR
        height: int.parse(heightCtrl.text),
        headCircumference:
            headCtrl.text.isEmpty ? null : int.parse(headCtrl.text),
        waistCircumference:
            waistCtrl.text.isEmpty ? null : int.parse(waistCtrl.text),
    );

    await GrowthStorage().addEntry(entry);

    // Baby profile'ı da güncelle
    final updated = BabyProfile(
        name: profile!.name,
        gender: profile!.gender,
        birthDate: profile!.birthDate,
        weight: entry.weight, // GR
        height: entry.height,
        headCircumference: entry.headCircumference,
        waistCircumference: entry.waistCircumference,
    );

    await BabyStorage().saveProfile(updated);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Growth Update")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // DISABLED FIELDS
            TextFormField(
              initialValue: profile!.name,
              decoration: const InputDecoration(labelText: "Bebek Adı"),
              enabled: false,
            ),
            TextFormField(
              initialValue: profile!.gender,
              decoration: const InputDecoration(labelText: "Cinsiyet"),
              enabled: false,
            ),
            TextFormField(
              initialValue:
                  "${profile!.birthDate.day}.${profile!.birthDate.month}.${profile!.birthDate.year}",
              decoration: const InputDecoration(labelText: "Doğum Tarihi"),
              enabled: false,
            ),

            const SizedBox(height: 20),

            // EDITABLE FIELDS
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Kilo (gr)"),
            ),
            TextField(
              controller: heightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Boy (cm)"),
            ),
            TextField(
              controller: headCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Kafa Çevresi (opsiyonel)"),
            ),
            TextField(
              controller: waistCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Bel Çevresi (opsiyonel)"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: save,
              child: const Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }
}
