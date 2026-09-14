import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../milk_batch.dart';

class MilkInventoryFilterBar extends StatelessWidget {
  const MilkInventoryFilterBar({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final MilkStorageLocation? value;
  final ValueChanged<MilkStorageLocation?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: _chip(context, l10n.all, null)),
        const SizedBox(width: 8),
        Expanded(
          child: _chip(
            context,
            l10n.refrigerator,
            MilkStorageLocation.refrigerator,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _chip(context, l10n.freezer, MilkStorageLocation.freezer),
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    MilkStorageLocation? option,
  ) {
    final selected = value == option;
    return GestureDetector(
      onTap: () => onChanged(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xff6D63E8)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xff6D63E8)
                : Theme.of(context).dividerColor.withAlpha(75),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? Colors.white : null,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
