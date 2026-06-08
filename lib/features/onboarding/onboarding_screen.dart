import 'package:flutter/material.dart';
import '../../models/baby_profile.dart';
import '../../services/baby_storage.dart';
import 'package:babyfeedpro/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final heightCtrl = TextEditingController();
  final headCtrl = TextEditingController();
  final waistCtrl = TextEditingController();

  String gender = "Male"; // 👈 Lokalizasyon için İngilizce default
  DateTime? birthDate;

  Future<void> pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => birthDate = picked);
    }
  }

  void save() async {
    final t = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) return;

    if (birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.birthDateNotSelected)),
      );
      return;
    }

    final profile = BabyProfile(
      name: nameCtrl.text.trim(),
      gender: gender,
      birthDate: birthDate!,
      weight: int.parse(weightCtrl.text),
      height: int.parse(heightCtrl.text),
      headCircumference:
          headCtrl.text.isEmpty ? null : int.parse(headCtrl.text),
      waistCircumference:
          waistCtrl.text.isEmpty ? null : int.parse(waistCtrl.text),
    );

    await BabyStorage().saveProfile(profile);

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.babyInfoTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NAME
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: t.babyNameLabel),
                validator: (v) =>
                    v == null || v.isEmpty ? t.requiredField : null,
              ),

              const SizedBox(height: 20),

              // GENDER
              DropdownButtonFormField<String>(
                value: gender,
                items: [
                  DropdownMenuItem(
                      value: "Male", child: Text(t.genderMale)),
                  DropdownMenuItem(
                      value: "Female", child: Text(t.genderFemale)),
                ],
                onChanged: (v) => setState(() => gender = v!),
                decoration: InputDecoration(labelText: t.genderLabel),
              ),

              const SizedBox(height: 20),

              // BIRTH DATE
              Row(
                children: [
                  Expanded(
                    child: Text(
                      birthDate == null
                          ? t.birthDateNotSelected
                          : "${birthDate!.day}.${birthDate!.month}.${birthDate!.year}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: pickBirthDate,
                    child: Text(t.selectDate),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // WEIGHT
              TextFormField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t.weightGr),
                validator: (v) =>
                    v == null || v.isEmpty ? t.requiredField : null,
              ),

              const SizedBox(height: 20),

              // HEIGHT
              TextFormField(
                controller: heightCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t.heightCm),
                validator: (v) =>
                    v == null || v.isEmpty ? t.requiredField : null,
              ),

              const SizedBox(height: 20),

              // OPTIONAL FIELDS
              TextFormField(
                controller: headCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: t.headCircumferenceOptional),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: waistCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: t.waistCircumferenceOptional),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(t.saveContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
