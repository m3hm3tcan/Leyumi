import 'package:flutter/material.dart';

class TimelineHeader extends StatelessWidget {
  final String title;
  final int count;

  const TimelineHeader({
    super.key,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 18,
        bottom: 10,
      ),
      child: Row(
        children: [
          // LEFT: TITLE
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.grey,
              decoration: TextDecoration.none,
            ),
          ),

          const SizedBox(width: 8),

          // DOT
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 8),

          // COUNT
          Text(
            "$count sessions",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              decoration: TextDecoration.none,
            ),
          ),

          const Spacer(),

          // optional right-side hint (future: filter / expand)
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}