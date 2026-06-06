import 'package:flutter/material.dart';
import 'package:babyfeedpro/l10n/app_localizations.dart';
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
  GrowthEntry? previousEntry;

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
    final growth = await GrowthStorage().loadEntries();

    setState(() {
      profile = p;

      if (growth.isNotEmpty) {
        previousEntry = growth.first;
      }
    });
  }

  Future<void> save() async {
    if (profile == null) return;

    final l10n = AppLocalizations.of(context);

    if (weightCtrl.text.isEmpty || heightCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.weightHeightRequired),
        ),
      );
      return;
    }

    final entry = GrowthEntry(
      date: DateTime.now(),
      weight: int.parse(weightCtrl.text),
      height: int.parse(heightCtrl.text),
      headCircumference:
          headCtrl.text.isEmpty ? null : int.parse(headCtrl.text),
      waistCircumference:
          waistCtrl.text.isEmpty ? null : int.parse(waistCtrl.text),
    );

    await GrowthStorage().addEntry(entry);

    final updated = BabyProfile(
      name: profile!.name,
      gender: profile!.gender,
      birthDate: profile!.birthDate,
      weight: entry.weight,
      height: entry.height,
      headCircumference: entry.headCircumference,
      waistCircumference: entry.waistCircumference,
    );

    await BabyStorage().saveProfile(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.growthRecordSaved),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isBoy = profile!.gender.toLowerCase() == "male";
    final primaryColor =
        isBoy ? const Color(0xff4DA3FF) : const Color(0xffFF6B9D);

    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      appBar: AppBar(
        title: Text(l10n.growthUpdateTitle),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            /// PROFILE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primaryColor.withAlpha(38),
                    child: Icon(
                      isBoy ? Icons.male : Icons.female,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          l10n.currentGrowthSnapshot,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// CURRENT STATS
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    l10n.weight,
                    "${profile!.weight} ${l10n.unitGr}",
                    Icons.monitor_weight_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    l10n.height,
                    "${profile!.height} ${l10n.unitCm}",
                    Icons.height,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _growthField(
              label: l10n.weight,
              currentValue: profile!.weight,
              controller: weightCtrl,
              icon: Icons.monitor_weight_outlined,
              unit: l10n.unitGr,
              currentLabel: l10n.currentLabel,
              hintText: l10n.enterNewValueHint,
            ),

            _growthField(
              label: l10n.height,
              currentValue: profile!.height,
              controller: heightCtrl,
              icon: Icons.height,
              unit: l10n.unitCm,
              currentLabel: l10n.currentLabel,
              hintText: l10n.enterNewValueHint,
            ),

            _growthField(
              label: l10n.headCircumference,
              currentValue: profile!.headCircumference ?? 0,
              controller: headCtrl,
              icon: Icons.circle_outlined,
              unit: l10n.unitCm,
              currentLabel: l10n.currentLabel,
              hintText: l10n.enterNewValueHint,
            ),

            _growthField(
              label: l10n.waistCircumference,
              currentValue: profile!.waistCircumference ?? 0,
              controller: waistCtrl,
              icon: Icons.straighten,
              unit: l10n.unitCm,
              currentLabel: l10n.currentLabel,
              hintText: l10n.enterNewValueHint,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: save,
                icon: const Icon(Icons.favorite),
                label: Text(
                  l10n.saveGrowthRecord,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _growthField({
    required String label,
    required int currentValue,
    required TextEditingController controller,
    required IconData icon,
    required String unit,
    required String currentLabel,
    required String hintText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),

              const SizedBox(width: 8),

              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "$currentLabel: $currentValue $unit",
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}