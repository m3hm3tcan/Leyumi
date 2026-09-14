import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/features/history/helpers/delete_confirmation.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/utils/app_date_utils.dart';
import 'session_card.dart';
import 'timeline_header.dart';
import 'timeline_item.dart';

class TimelineSection extends StatelessWidget {
  final String title;
  final List<FeedingSession> sessions;
  final String? summary;
  final bool collapsible;
  final Function(FeedingSession) onDelete;
  final Function(FeedingSession)? onEdit;
  final Function(FeedingSession)? onAddToMeal;

  const TimelineSection({
    super.key,
    required this.title,
    required this.sessions,
    this.summary,
    this.collapsible = false,
    required this.onDelete,
    this.onEdit,
    this.onAddToMeal,
  });

  @override
  Widget build(BuildContext context) {
    if (collapsible) {
      final theme = Theme.of(context);
      final secondaryTextColor =
          theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 7, 16, 7),
        decoration: BoxDecoration(
          color: theme.cardColor.withAlpha(
            theme.brightness == Brightness.dark ? 220 : 248,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xff4DA3FF).withAlpha(28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 5,
            ),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xff4DA3FF).withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 19,
                color: Color(0xff4DA3FF),
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
            subtitle: summary == null
                ? null
                : Text(
                    summary!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: secondaryTextColor,
                    ),
                  ),
            children: [_sessionList()],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TimelineHeader(title: title, count: sessions.length),
        _sessionList(),
      ],
    );
  }

  Widget _sessionList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final session = sessions[index];

        return Dismissible(
          key: ValueKey(session.id),
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
          confirmDismiss: (_) => confirmHistoryDelete(
            context,
            detail: session.bottles.any((b) => b.batchId != null)
                ? AppLocalizations.of(context).feedingStockCorrection
                : null,
          ),
          onDismissed: (_) => onDelete(session),
          child: TimelineItem(
            isLast: index == sessions.length - 1,
            child: SessionCard(
              session: session,
              onAddToMeal: onAddToMeal == null
                  ? null
                  : () => onAddToMeal!(session),
              onEdit: AppDateUtils.isToday(session.startTime)
                  ? () => onEdit?.call(session)
                  : null,
            ),
          ),
        );
      },
    );
  }
}
