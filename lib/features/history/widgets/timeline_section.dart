import 'package:flutter/material.dart';
import 'package:babyfeedpro/features/feeding/feeding_session.dart';
import 'session_card.dart';
import 'timeline_header.dart';
import 'timeline_item.dart';

class TimelineSection extends StatelessWidget {
  final String title;
  final List<FeedingSession> sessions;

  const TimelineSection({
    super.key,
    required this.title,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ─────────────────────────────
        /// SECTION HEADER (MODERN)
        /// ─────────────────────────────
        TimelineHeader(
          title: title,
          count: sessions.length,
        ),

        /// ─────────────────────────────
        /// SESSION LIST
        /// ─────────────────────────────
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: sessions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            final session = sessions[index];

            return TimelineItem(
              isLast: index == sessions.length - 1,
              child: SessionCard(
                session: session,
              ),
            );
                  // return Padding(
            //   padding: EdgeInsets.only(
            //     bottom: index == sessions.length - 1 ? 8 : 0,
            //   ),
            //   child: SessionCard(session: session),
            // );
          },
        ),
      ],
    );
  }
}