import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/feeding_storage.dart';
import '../../feeding/feeding_screen.dart';

class LiveFeedingHomeCard extends StatefulWidget {
  const LiveFeedingHomeCard({super.key, required this.refreshVersion});

  final int refreshVersion;

  @override
  State<LiveFeedingHomeCard> createState() => _LiveFeedingHomeCardState();
}

class _LiveFeedingHomeCardState extends State<LiveFeedingHomeCard> {
  Timer? _timer;
  Map<String, dynamic>? _draft;

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _draft != null) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant LiveFeedingHomeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) _loadDraft();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final draft = await FeedingStorage().loadActiveDraft();
    if (!mounted) return;
    setState(() => _draft = draft);
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_draft == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final activeSide = _draft!['activeSide'] as String?;
    final activeStartedAtRaw = _draft!['activeSideStartedAt'] as String?;
    final startedAt = activeStartedAtRaw == null
        ? null
        : DateTime.tryParse(activeStartedAtRaw);
    final elapsed = startedAt == null
        ? Duration.zero
        : DateTime.now().difference(startedAt);
    final sideLabel = activeSide == 'left' ? l10n.leftLabel : l10n.rightLabel;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffFF8A65), Color(0xffFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(46),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.timer_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.liveFeedingContinues,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activeSide == null
                      ? l10n.unsavedFeedingDraft
                      : l10n.feedingSideProgress(sideLabel, _format(elapsed)),
                  style: TextStyle(
                    color: Colors.white.withAlpha(235),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedingScreen()),
              );
              await _loadDraft();
            },
            child: Text(
              l10n.open,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
