import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:flutter/material.dart';

import 'session_card.dart';
import 'timeline_header.dart';
import 'timeline_item.dart';

class TimelineSection extends StatelessWidget {
  final String title;
  final List<FeedingSession> sessions;
  final Function(FeedingSession) onDelete;

  const TimelineSection({
    super.key,
    required this.title,
    required this.sessions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TimelineHeader(
          title: title,
          count: sessions.length,
        ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            final session = sessions[index];

            return Dismissible(
              key: ValueKey(session.startTime.toIso8601String()),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(
                  left: 48,
                  right: 16,
                  top: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              onDismissed: (_) => onDelete(session),
              child: TimelineItem(
                isLast: index == sessions.length - 1,
                child: SessionCard(session: session),
              ),
            );
          },
        ),
      ],
    );
  }
}
