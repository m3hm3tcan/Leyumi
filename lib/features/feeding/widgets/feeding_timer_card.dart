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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xff4DA3FF), Color(0xff7CC5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xff4DA3FF),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: activeSide != null
                      ? Colors.greenAccent
                      : Colors.white70,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                activeSide != null ? l10n.liveSession : l10n.ready,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _format(elapsed),
            style: GoogleFonts.poppins(
              fontSize: 72,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _statusLabel(l10n),
            style: GoogleFonts.poppins(
              color: Colors.white.withAlpha(230),
              fontSize: 15,
              fontWeight: FontWeight.w500,
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

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
