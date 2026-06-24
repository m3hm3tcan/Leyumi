import 'package:flutter/material.dart';

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({
    super.key,
    this.compact = false,
    this.foregroundColor = Colors.white,
    this.backgroundColor,
  });

  final bool compact;
  final Color foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 8,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withAlpha(45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            color: foregroundColor,
            size: compact ? 11 : 12,
          ),
          const SizedBox(width: 3),
          Text(
            'PRO',
            style: TextStyle(
              color: foregroundColor,
              fontSize: compact ? 8 : 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}
