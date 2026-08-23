import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../diaper/diaper_entry.dart';
import '../quick_diaper_service.dart';

class QuickDiaperCard extends StatefulWidget {
  const QuickDiaperCard({
    super.key,
    required this.childId,
    required this.onChanged,
    required this.onOpenDetails,
    this.service,
  });

  final String childId;
  final VoidCallback onChanged;
  final VoidCallback onOpenDetails;
  final QuickDiaperService? service;

  @override
  State<QuickDiaperCard> createState() => _QuickDiaperCardState();
}

class _QuickDiaperCardState extends State<QuickDiaperCard> {
  late final QuickDiaperService _service;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? QuickDiaperService();
  }

  Future<void> _save(DiaperType type) async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      final entry = await _service.save(childId: widget.childId, type: type);
      if (entry == null || !mounted) return;

      unawaited(_safeHaptic(HapticFeedback.lightImpact));
      widget.onChanged();
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(_savedMessage(type, l10n)),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => _undo(entry),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.quickDiaperSaveFailed)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _undo(DiaperEntry entry) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _service.undo(entry);
      if (!mounted) return;
      unawaited(_safeHaptic(HapticFeedback.selectionClick));
      widget.onChanged();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.quickDiaperUndone)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.quickDiaperUndoFailed)));
    }
  }

  String _savedMessage(DiaperType type, AppLocalizations l10n) =>
      switch (type) {
        DiaperType.pee => l10n.quickPeeSaved,
        DiaperType.poop => l10n.quickPoopSaved,
        DiaperType.both => l10n.quickBothSaved,
      };

  Future<void> _safeHaptic(Future<void> Function() feedback) async {
    try {
      await feedback();
    } catch (_) {
      // Haptics are optional and must not affect a saved record.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 13),
      borderRadius: 22,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xff38AFA9).withAlpha(13),
              const Color(0xff6DD5C3).withAlpha(7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 0, 8),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff38AFA9), Color(0xff6DD5C3)],
                        ),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.quickDiaperTitle,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            l10n.quickDiaperSubtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color?.withAlpha(155),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (_saving)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 9),
                        child: SizedBox.square(
                          dimension: 19,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: widget.onOpenDetails,
                        child: Text(l10n.details),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _QuickTypeButton(
                      icon: Icons.water_drop_rounded,
                      label: l10n.quickWet,
                      color: const Color(0xff45A7D9),
                      enabled: !_saving,
                      onTap: () => _save(DiaperType.pee),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _QuickTypeButton(
                      icon: Icons.circle_rounded,
                      label: l10n.quickDirty,
                      color: const Color(0xffC78A54),
                      enabled: !_saving,
                      onTap: () => _save(DiaperType.poop),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _QuickTypeButton(
                      icon: Icons.auto_awesome_rounded,
                      label: l10n.quickBoth,
                      color: const Color(0xff6D72D9),
                      enabled: !_saving,
                      onTap: () => _save(DiaperType.both),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTypeButton extends StatelessWidget {
  const _QuickTypeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withAlpha(42)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 19),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
