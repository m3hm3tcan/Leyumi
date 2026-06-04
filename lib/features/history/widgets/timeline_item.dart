import 'package:flutter/material.dart';

class TimelineItem extends StatelessWidget {
  final Widget child;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.child,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// ─────────────────────
          /// TIMELINE (DOT + LINE)
          /// ─────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 12),
            child: Column(
              children: [
                /// DOT
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xff4DA3FF),
                    shape: BoxShape.circle,
                  ),
                ),

                /// LINE
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /// ─────────────────────
          /// CONTENT
          /// ─────────────────────
          Expanded(child: child),
        ],
      ),
    );
  }
}