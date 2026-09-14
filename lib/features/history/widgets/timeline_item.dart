import 'package:flutter/material.dart';

class TimelineItem extends StatelessWidget {
  final Widget child;
  final bool isLast;

  const TimelineItem({super.key, required this.child, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 12),
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xff4DA3FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.cardColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff4DA3FF).withAlpha(70),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xff4DA3FF).withAlpha(50)
                            : const Color(0xff4DA3FF).withAlpha(42),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
