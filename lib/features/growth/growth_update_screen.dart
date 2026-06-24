import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leyumi/l10n/app_localizations.dart';
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
  final _weightFocus = FocusNode();
  final _heightFocus = FocusNode();
  final _headFocus = FocusNode();
  final _waistFocus = FocusNode();

  String? _weightError;
  String? _heightError;
  String? _headError;
  String? _waistError;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final p = await BabyStorage().loadProfile();
    final growth = await GrowthStorage().loadEntries();

    if (!mounted) return;

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
    final weight = int.tryParse(weightCtrl.text);
    final height = int.tryParse(heightCtrl.text);
    final head = headCtrl.text.isEmpty ? null : int.tryParse(headCtrl.text);
    final waist = waistCtrl.text.isEmpty ? null : int.tryParse(waistCtrl.text);

    setState(() {
      _weightError = weight == null || weight < 500 || weight > 30000
          ? l10n.weightRangeError
          : null;
      _heightError = height == null || height < 20 || height > 100
          ? l10n.heightRangeError
          : null;
      _headError =
          headCtrl.text.isNotEmpty && (head == null || head < 20 || head > 70)
          ? l10n.headCircumferenceRangeError
          : null;
      _waistError =
          waistCtrl.text.isNotEmpty &&
              (waist == null || waist < 20 || waist > 100)
          ? l10n.waistCircumferenceRangeError
          : null;
    });

    final firstInvalidFocus = _weightError != null
        ? _weightFocus
        : _heightError != null
        ? _heightFocus
        : _headError != null
        ? _headFocus
        : _waistError != null
        ? _waistFocus
        : null;
    if (firstInvalidFocus != null) {
      firstInvalidFocus.requestFocus();
      return;
    }

    final entry = GrowthEntry(
      childId: profile!.id,
      date: DateTime.now(),
      weight: weight!,
      height: height!,
      headCircumference: head,
      waistCircumference: waist,
    );

    await GrowthStorage().addEntry(entry);

    final updated = profile!.copyWith(
      weight: entry.weight,
      height: entry.height,
      headCircumference: entry.headCircumference,
      waistCircumference: entry.waistCircumference,
      clearHeadCircumference: entry.headCircumference == null,
      clearWaistCircumference: entry.waistCircumference == null,
    );

    await BabyStorage().saveProfile(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.growthRecordSaved)));

    Navigator.pop(context);
  }

  @override
  void dispose() {
    weightCtrl.dispose();
    heightCtrl.dispose();
    headCtrl.dispose();
    waistCtrl.dispose();
    _weightFocus.dispose();
    _heightFocus.dispose();
    _headFocus.dispose();
    _waistFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isBoy = profile!.gender.toLowerCase() == "male";
    final primaryColor = isBoy
        ? const Color(0xff4DA3FF)
        : const Color(0xffFF6B9D);
    final surfaceColor = theme.cardColor;
    final subtleSurface = isDark
        ? const Color(0xff262626)
        : const Color(0xffF4F6FA);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;
    final shadowColor = Colors.black.withAlpha(isDark ? 40 : 10);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.growthUpdateTitle), elevation: 0),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            /// PROFILE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
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
                          style: TextStyle(
                            color: secondaryTextColor,
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
                    surfaceColor: surfaceColor,
                    secondaryTextColor: secondaryTextColor,
                    iconColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard(
                    l10n.height,
                    "${profile!.height} ${l10n.unitCm}",
                    Icons.height,
                    surfaceColor: surfaceColor,
                    secondaryTextColor: secondaryTextColor,
                    iconColor: colorScheme.primary,
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
              surfaceColor: surfaceColor,
              subtleSurface: subtleSurface,
              secondaryTextColor: secondaryTextColor,
              accentColor: primaryColor,
              focusNode: _weightFocus,
              maxDigits: 5,
              errorText: _weightError,
              onChanged: (_) {
                if (_weightError != null) {
                  setState(() => _weightError = null);
                }
              },
            ),

            _growthField(
              label: l10n.height,
              currentValue: profile!.height,
              controller: heightCtrl,
              icon: Icons.height,
              unit: l10n.unitCm,
              currentLabel: l10n.currentLabel,
              hintText: l10n.enterNewValueHint,
              surfaceColor: surfaceColor,
              subtleSurface: subtleSurface,
              secondaryTextColor: secondaryTextColor,
              accentColor: primaryColor,
              focusNode: _heightFocus,
              maxDigits: 3,
              errorText: _heightError,
              onChanged: (_) {
                if (_heightError != null) {
                  setState(() => _heightError = null);
                }
              },
            ),

            _growthField(
              label: l10n.headCircumference,
              currentValue: profile!.headCircumference ?? 0,
              controller: headCtrl,
              icon: Icons.circle_outlined,
              unit: l10n.unitCm,
              currentLabel: l10n.currentLabel,
              hintText: l10n.enterNewValueHint,
              surfaceColor: surfaceColor,
              subtleSurface: subtleSurface,
              secondaryTextColor: secondaryTextColor,
              accentColor: primaryColor,
              focusNode: _headFocus,
              maxDigits: 2,
              errorText: _headError,
              onChanged: (_) {
                if (_headError != null) setState(() => _headError = null);
              },
            ),

            _growthField(
              label: l10n.waistCircumference,
              currentValue: profile!.waistCircumference ?? 0,
              controller: waistCtrl,
              icon: Icons.straighten,
              unit: l10n.unitCm,
              currentLabel: l10n.currentLabel,
              hintText: l10n.enterNewValueHint,
              surfaceColor: surfaceColor,
              subtleSurface: subtleSurface,
              secondaryTextColor: secondaryTextColor,
              accentColor: primaryColor,
              focusNode: _waistFocus,
              maxDigits: 3,
              errorText: _waistError,
              onChanged: (_) {
                if (_waistError != null) setState(() => _waistError = null);
              },
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
    IconData icon, {
    required Color surfaceColor,
    required Color secondaryTextColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(color: secondaryTextColor, fontSize: 12),
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
    required Color surfaceColor,
    required Color subtleSurface,
    required Color secondaryTextColor,
    required Color accentColor,
    required FocusNode focusNode,
    required int maxDigits,
    required String? errorText,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),

              const SizedBox(width: 8),

              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            "$currentLabel: $currentValue $unit",
            style: TextStyle(color: secondaryTextColor),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(maxDigits),
            ],
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: subtleSurface,
              hintText: hintText,
              errorText: errorText,
              prefixIcon: Icon(
                icon,
                color: errorText == null
                    ? accentColor
                    : Theme.of(context).colorScheme.error,
              ),
              suffixIcon: errorText == null
                  ? null
                  : Icon(
                      Icons.error_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor.withAlpha(90),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: accentColor.withAlpha(140),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                  width: 2.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
