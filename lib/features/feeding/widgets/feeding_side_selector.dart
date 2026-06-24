import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../feeding_entry.dart';

class FeedingSideSelector extends StatelessWidget {
  const FeedingSideSelector({
    super.key,
    required this.activeSide,
    required this.leftDuration,
    required this.rightDuration,
    required this.onSelected,
  });

  final FeedingSide? activeSide;
  final Duration leftDuration;
  final Duration rightDuration;
  final ValueChanged<FeedingSide> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SideCard(
            side: FeedingSide.left,
            activeSide: activeSide,
            duration: leftDuration,
            onTap: onSelected,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _SideCard(
            side: FeedingSide.right,
            activeSide: activeSide,
            duration: rightDuration,
            onTap: onSelected,
          ),
        ),
      ],
    );
  }
}

class _SideCard extends StatelessWidget {
  const _SideCard({
    required this.side,
    required this.activeSide,
    required this.duration,
    required this.onTap,
  });

  final FeedingSide side;
  final FeedingSide? activeSide;
  final Duration duration;
  final ValueChanged<FeedingSide> onTap;

  bool get isActive => activeSide == side;
  bool get isLeft => side == FeedingSide.left;
  Color get accent => isLeft ? Colors.pink : const Color(0xff4DA3FF);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: activeSide == null ? () => onTap(side) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 145,
        decoration: BoxDecoration(
          color: isActive ? accent.withAlpha(38) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isActive ? accent : Theme.of(context).dividerColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: accent, size: 34),
            const SizedBox(height: 12),
            Text(
              isLeft ? l10n.leftSide : l10n.rightSide,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${duration.inMinutes}m',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.live,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
