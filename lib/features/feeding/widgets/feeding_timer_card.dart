import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../feeding_entry.dart';

class FeedingTimerCard extends StatelessWidget {
  const FeedingTimerCard({
    super.key,
    required this.elapsed,
    required this.activeSide,
  });

  final Duration elapsed;
  final FeedingSide? activeSide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isActive = activeSide != null;
    final accent = switch (activeSide) {
      FeedingSide.left => const Color(0xffE96B9B),
      FeedingSide.right => const Color(0xff4D8FE8),
      null => theme.colorScheme.primary,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xff171A20)
            : const Color(0xffF7F9FC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withAlpha(isActive ? 115 : 45)),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(isActive ? 22 : 8),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _LiveIndicator(active: isActive, color: accent),
              const SizedBox(width: 8),
              Text(
                isActive ? l10n.liveSession : l10n.ready,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .8,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: theme.textTheme.bodySmall?.color?.withAlpha(130),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            label: _format(elapsed),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DigitalPair(value: _minutes(elapsed), accent: accent),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: isActive && elapsed.inSeconds.isOdd ? .35 : 1,
                    child: Text(
                      ':',
                      style: GoogleFonts.robotoMono(
                        fontSize: 35,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ),
                _DigitalPair(value: _seconds(elapsed), accent: accent),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Text(
            _statusLabel(l10n),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withAlpha(165),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n) {
    return switch (activeSide) {
      FeedingSide.left => l10n.leftSide,
      FeedingSide.right => l10n.rightSide,
      null => l10n.tapLeftOrRightToStart,
    };
  }

  String _minutes(Duration duration) =>
      duration.inMinutes.toString().padLeft(2, '0');

  String _seconds(Duration duration) =>
      duration.inSeconds.remainder(60).toString().padLeft(2, '0');

  String _format(Duration duration) =>
      '${_minutes(duration)}:${_seconds(duration)}';
}

class _DigitalPair extends StatelessWidget {
  const _DigitalPair({required this.value, required this.accent});

  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 86,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff0C0F14) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withAlpha(45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 35 : 10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: GoogleFonts.robotoMono(
          fontSize: 34,
          height: 1,
          fontWeight: FontWeight.w700,
          letterSpacing: 4,
          color: accent,
        ),
      ),
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  const _LiveIndicator({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: active ? color : color.withAlpha(90),
        shape: BoxShape.circle,
        boxShadow: active
            ? [BoxShadow(color: color.withAlpha(80), blurRadius: 6)]
            : null,
      ),
    );
  }
}
