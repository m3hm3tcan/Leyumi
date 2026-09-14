import 'package:flutter/material.dart';
import 'package:leyumi/l10n/app_localizations.dart';

class TimelineHeader extends StatelessWidget {
  final String title;
  final int count;

  const TimelineHeader({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(170) ??
        Colors.grey;

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xff4DA3FF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: secondaryTextColor,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: secondaryTextColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count ${l10n.sessions.toLowerCase()}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: secondaryTextColor,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: secondaryTextColor,
          ),
        ],
      ),
    );
  }
}
