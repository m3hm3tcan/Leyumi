import 'package:flutter/material.dart';
import '../../models/baby_profile.dart';
import '../../services/baby_storage.dart';

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

  String gender = "Erkek";
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
    if (!_formKey.currentState!.validate()) return;
    if (birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen doğum tarihini seçin")),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Bebek Bilgileri")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NAME
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Bebek Adı"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Bu alan zorunludur" : null,
              ),

              const SizedBox(height: 20),

              // GENDER
              DropdownButtonFormField<String>(
                value: gender,
                items: const [
                  DropdownMenuItem(value: "Erkek", child: Text("Erkek")),
                  DropdownMenuItem(value: "Kız", child: Text("Kız")),
                ],
                onChanged: (v) => setState(() => gender = v!),
                decoration: const InputDecoration(labelText: "Cinsiyet"),
              ),

              const SizedBox(height: 20),

              // BIRTH DATE
              Row(
                children: [
                  Expanded(
                    child: Text(
                      birthDate == null
                          ? "Doğum tarihi seçilmedi"
                          : "${birthDate!.day}.${birthDate!.month}.${birthDate!.year}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: pickBirthDate,
                    child: const Text("Tarih Seç"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // WEIGHT
              TextFormField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Kilo (gr)"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Bu alan zorunludur" : null,
            ),

              const SizedBox(height: 20),

              // HEIGHT
              TextFormField(
                controller: heightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Boy (cm)"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Bu alan zorunludur" : null,
              ),

              const SizedBox(height: 20),

              // OPTIONAL FIELDS
              TextFormField(
                controller: headCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Kafa Çevresi (opsiyonel)"),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: waistCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Bel Çevresi (opsiyonel)"),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Kaydet ve Devam Et"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
