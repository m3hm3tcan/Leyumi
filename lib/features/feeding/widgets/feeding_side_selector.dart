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
        const SizedBox(width: 12),
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

class _SideCard extends StatefulWidget {
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

  @override
  State<_SideCard> createState() => _SideCardState();
}

class _SideCardState extends State<_SideCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _nursingController;

  bool get isActive => widget.activeSide == widget.side;
  bool get isLeft => widget.side == FeedingSide.left;
  Color get accent =>
      isLeft ? const Color(0xffE96B9B) : const Color(0xff4D8FE8);

  @override
  void initState() {
    super.initState();
    _nursingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
    if (isActive) _nursingController.repeat();
  }

  @override
  void didUpdateWidget(covariant _SideCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isActive && !_nursingController.isAnimating) {
      _nursingController.repeat();
    } else if (!isActive && _nursingController.isAnimating) {
      _nursingController
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _nursingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final disabled = widget.activeSide != null && !isActive;

    return Semantics(
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: widget.activeSide == null
            ? () => widget.onTap(widget.side)
            : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: disabled ? .55 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            height: 116,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? accent.withAlpha(18) : theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? accent : theme.dividerColor.withAlpha(85),
                width: isActive ? 1.7 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? accent.withAlpha(20)
                      : Colors.black.withAlpha(8),
                  blurRadius: isActive ? 13 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _NursingPulse(
                  animation: _nursingController,
                  active: isActive,
                  color: accent,
                  mirror: !isLeft,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLeft ? l10n.leftSide : l10n.rightSide,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _format(widget.duration),
                        style: GoogleFonts.robotoMono(
                          color: accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          isActive ? l10n.live : l10n.ready.toUpperCase(),
                          key: ValueKey(isActive),
                          style: TextStyle(
                            color: isActive
                                ? accent
                                : theme.textTheme.bodySmall?.color?.withAlpha(
                                    120,
                                  ),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _NursingPulse extends StatelessWidget {
  const _NursingPulse({
    required this.animation,
    required this.active,
    required this.color,
    required this.mirror,
  });

  final Animation<double> animation;
  final bool active;
  final Color color;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 72,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final pulse = active
              ? Curves.easeInOut.transform(
                  animation.value <= .5
                      ? animation.value * 2
                      : (1 - animation.value) * 2,
                )
              : 0.0;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(mirror ? -1.0 : 1.0, 1, 1),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (active)
                  Container(
                    width: 42 + (pulse * 8),
                    height: 42 + (pulse * 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withAlpha((70 * (1 - pulse)).round()),
                        width: 2,
                      ),
                    ),
                  ),
                Transform.scale(
                  scale: 1 + (pulse * .06),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withAlpha(active ? 30 : 18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.child_care_rounded,
                      color: color,
                      size: 25,
                    ),
                  ),
                ),
                if (active)
                  Positioned(
                    right: 0,
                    top: 16 + (pulse * 4),
                    child: Icon(
                      Icons.water_drop_rounded,
                      color: color.withAlpha((210 - pulse * 70).round()),
                      size: 11,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
