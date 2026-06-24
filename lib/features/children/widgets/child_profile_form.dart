import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/baby_profile.dart';

class ChildProfileForm extends StatefulWidget {
  const ChildProfileForm({
    super.key,
    required this.onSaved,
    this.initialProfile,
    this.submitLabel,
  });

  final BabyProfile? initialProfile;
  final ValueChanged<BabyProfile> onSaved;
  final String? submitLabel;

  @override
  State<ChildProfileForm> createState() => _ChildProfileFormState();
}

class _ChildProfileFormState extends State<ChildProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late final TextEditingController _head;
  late final TextEditingController _waist;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _heightFocus = FocusNode();
  final FocusNode _headFocus = FocusNode();
  final FocusNode _waistFocus = FocusNode();
  final GlobalKey _birthDateKey = GlobalKey();
  late String _gender;
  DateTime? _birthDate;
  bool _birthDateHasError = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _name = TextEditingController(text: profile?.name ?? '');
    _weight = TextEditingController(text: profile?.weight.toString() ?? '');
    _height = TextEditingController(text: profile?.height.toString() ?? '');
    _head = TextEditingController(
      text: profile?.headCircumference?.toString() ?? '',
    );
    _waist = TextEditingController(
      text: profile?.waistCircumference?.toString() ?? '',
    );
    _gender = profile?.gender ?? 'Male';
    _birthDate = profile?.birthDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _height.dispose();
    _head.dispose();
    _waist.dispose();
    _nameFocus.dispose();
    _weightFocus.dispose();
    _heightFocus.dispose();
    _headFocus.dispose();
    _waistFocus.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateHasError = false;
      });
    }
  }

  void _save() {
    final l10n = AppLocalizations.of(context);
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      _focusFirstInvalidField();
      return;
    }
    if (_birthDate == null) {
      setState(() => _birthDateHasError = true);
      final dateContext = _birthDateKey.currentContext;
      if (dateContext != null) {
        Scrollable.ensureVisible(
          dateContext,
          duration: const Duration(milliseconds: 250),
          alignment: .3,
        );
      }
      return;
    }

    final existing = widget.initialProfile;
    widget.onSaved(
      BabyProfile(
        id: existing?.id,
        name: _name.text.trim(),
        gender: _gender,
        birthDate: _birthDate!,
        weight: int.parse(_weight.text),
        height: int.parse(_height.text),
        headCircumference: int.tryParse(_head.text),
        waistCircumference: int.tryParse(_waist.text),
        createdAt: existing?.createdAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _name,
            focusNode: _nameFocus,
            maxLength: 30,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              context,
              label: l10n.babyNameLabel,
              icon: Icons.badge_outlined,
            ),
            validator: (value) {
              final requiredError = _required(value);
              if (requiredError != null) return requiredError;
              return value!.trim().length < 2 ? l10n.nameLengthError : null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            decoration: InputDecoration(labelText: l10n.genderLabel),
            items: [
              DropdownMenuItem(value: 'Male', child: Text(l10n.genderMale)),
              DropdownMenuItem(value: 'Female', child: Text(l10n.genderFemale)),
            ],
            onChanged: (value) => setState(() => _gender = value ?? 'Male'),
          ),
          const SizedBox(height: 16),
          Container(
            key: _birthDateKey,
            decoration: BoxDecoration(
              color: _birthDateHasError
                  ? Theme.of(context).colorScheme.error.withAlpha(12)
                  : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _birthDateHasError
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).dividerColor,
                width: _birthDateHasError ? 2 : 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              onTap: _pickBirthDate,
              leading: Icon(
                Icons.cake_rounded,
                color: _birthDateHasError
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
              title: Text(
                _birthDate == null
                    ? l10n.birthDateNotSelected
                    : MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(_birthDate!),
              ),
              subtitle: _birthDateHasError
                  ? Text(
                      l10n.birthDateNotSelected,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : null,
              trailing: _birthDateHasError
                  ? Icon(
                      Icons.error_rounded,
                      color: Theme.of(context).colorScheme.error,
                    )
                  : Text(l10n.selectDate),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  _weight,
                  l10n.weightGr,
                  isRequired: true,
                  minimum: 500,
                  maximum: 30000,
                  rangeError: l10n.weightRangeError,
                  maxDigits: 5,
                  focusNode: _weightFocus,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(
                  _height,
                  l10n.heightCm,
                  isRequired: true,
                  minimum: 20,
                  maximum: 100,
                  rangeError: l10n.heightRangeError,
                  maxDigits: 3,
                  focusNode: _heightFocus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _numberField(
            _head,
            l10n.headCircumferenceOptional,
            minimum: 20,
            maximum: 70,
            rangeError: l10n.headCircumferenceRangeError,
            maxDigits: 2,
            focusNode: _headFocus,
          ),
          const SizedBox(height: 16),
          _numberField(
            _waist,
            l10n.waistCircumferenceOptional,
            minimum: 20,
            maximum: 100,
            rangeError: l10n.waistCircumferenceRangeError,
            maxDigits: 3,
            focusNode: _waistFocus,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(widget.submitLabel ?? l10n.saveContinue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    int? minimum,
    int? maximum,
    String? rangeError,
    required int maxDigits,
    required FocusNode focusNode,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxDigits),
      ],
      decoration: _inputDecoration(
        context,
        label: label,
        icon: Icons.numbers_rounded,
      ),
      validator: (value) {
        if (isRequired) {
          final requiredError = _required(value);
          if (requiredError != null) return requiredError;
        }
        if (value == null || value.isEmpty) return null;
        final number = int.tryParse(value);
        if (number == null ||
            (minimum != null && number < minimum) ||
            (maximum != null && number > maximum)) {
          return rangeError;
        }
        return null;
      },
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? AppLocalizations.of(context).requiredField
        : null;
  }

  void _focusFirstInvalidField() {
    final name = _name.text.trim();
    final weight = int.tryParse(_weight.text);
    final height = int.tryParse(_height.text);
    final head = _head.text.isEmpty ? null : int.tryParse(_head.text);
    final waist = _waist.text.isEmpty ? null : int.tryParse(_waist.text);

    if (name.length < 2 || name.length > 30) {
      _nameFocus.requestFocus();
    } else if (weight == null || weight < 500 || weight > 30000) {
      _weightFocus.requestFocus();
    } else if (height == null || height < 20 || height > 100) {
      _heightFocus.requestFocus();
    } else if (_head.text.isNotEmpty &&
        (head == null || head < 20 || head > 70)) {
      _headFocus.requestFocus();
    } else if (_waist.text.isNotEmpty &&
        (waist == null || waist < 20 || waist > 100)) {
      _waistFocus.requestFocus();
    }
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.dividerColor.withAlpha(90)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2.5),
      ),
    );
  }
}
