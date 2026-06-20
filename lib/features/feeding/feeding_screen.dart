import 'package:leyumi/features/feeding/feeding_entry.dart';
import 'package:leyumi/features/feeding/feeding_session.dart';
import 'package:leyumi/l10n/app_localizations.dart';
import 'package:leyumi/services/feeding_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'feeding_controller.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen>
    with WidgetsBindingObserver {
  late FeedingController controller;
  final FeedingStorage _storage = FeedingStorage();

  Duration currentTimer = Duration.zero;
  FeedingSide? activeSide;

  final startWeightCtrl = TextEditingController();
  final endWeightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = FeedingController(
      onTick: (duration) {
        if (!mounted) return;
        setState(() => currentTimer = duration);
      },
    );
    _restoreDraft();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    startWeightCtrl.dispose();
    endWeightCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _persistDraft();
    }
  }

  Future<void> _restoreDraft() async {
    final draft = await _storage.loadActiveDraft();
    if (draft == null || !mounted) return;

    final rawSession = draft["session"];
    if (rawSession is! Map<String, dynamic>) return;

    final session = FeedingSession.fromJson(rawSession);
    final sideName = draft["activeSide"] as String?;
    final restoredSide = sideName == "left"
        ? FeedingSide.left
        : sideName == "right"
            ? FeedingSide.right
            : null;
    final activeStartedAtRaw = draft["activeSideStartedAt"] as String?;
    final activeStartedAt = activeStartedAtRaw == null
        ? null
        : DateTime.tryParse(activeStartedAtRaw);

    controller.restoreDraft(
      session: session,
      draftActiveSide: restoredSide,
      draftActiveSideStartedAt: activeStartedAt,
      draftStartWeightGr: draft["startWeightGr"] as int?,
      draftEndWeightGr: draft["endWeightGr"] as int?,
    );

    startWeightCtrl.text = (draft["startWeightGr"] as int?)?.toString() ?? "";
    endWeightCtrl.text = (draft["endWeightGr"] as int?)?.toString() ?? "";

    setState(() {
      activeSide = restoredSide;
      currentTimer = activeStartedAt == null
          ? Duration.zero
          : DateTime.now().difference(activeStartedAt);
    });
  }

  Future<void> _persistDraft() async {
    final session = controller.currentSession;
    if (session == null) {
      await _storage.clearActiveDraft();
      return;
    }

    await _storage.saveActiveDraft({
      "session": session.toJson(),
      "activeSide": activeSide?.name,
      "activeSideStartedAt": controller.activeSideStartedAt?.toIso8601String(),
      "startWeightGr": controller.startWeightGr,
      "endWeightGr": controller.endWeightGr,
    });
  }

  Future<bool> _handleBackPress() async {
    await _persistDraft();
    if (!mounted) return true;

    if (controller.currentSession != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Live feeding arka planda kaydedildi."),
          duration: Duration(seconds: 2),
        ),
      );
    }

    return true;
  }

  void _openManualAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ManualFeedingModal(
        onSave: (session) async {
          await FeedingStorage().saveSession(session);
          if (!mounted) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  String formatTime(Duration duration) {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> startFeeding(FeedingSide side) async {
    if (controller.currentSession == null && startWeightCtrl.text.isNotEmpty) {
      controller.setStartWeight(int.parse(startWeightCtrl.text));
    }

    setState(() {
      activeSide = side;
      currentTimer = Duration.zero;
    });

    controller.startSide(side);
    await _persistDraft();
  }

  Future<void> stopFeeding() async {
    if (activeSide == null) return;

    controller.stopSide(activeSide!);

    setState(() {
      activeSide = null;
      currentTimer = Duration.zero;
    });

    await _persistDraft();
  }

  Future<void> finishSession() async {
    if (endWeightCtrl.text.isNotEmpty) {
      controller.setEndWeight(int.parse(endWeightCtrl.text));
    }

    final session = controller.finishSession();
    await FeedingStorage().saveSession(session);
    await _storage.clearActiveDraft();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = controller.currentSession?.entries ?? [];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _handleBackPress() && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.feedingSessionTitle),
          centerTitle: true,
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _openManualAddModal,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (controller.currentSession == null) ...[
                Text(
                  l10n.babyWeightGr,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: startWeightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: l10n.exampleWeight,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff4DA3FF),
                      Color(0xff7CC5FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xff4DA3FF),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: activeSide != null
                                ? Colors.greenAccent
                                : Colors.white70,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          activeSide != null ? l10n.liveSession : l10n.ready,
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).cardColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      formatTime(currentTimer),
                      style: GoogleFonts.poppins(
                        fontSize: 72,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activeSide == null
                          ? l10n.tapLeftOrRightToStart
                          : activeSide == FeedingSide.left
                              ? l10n.leftSide
                              : l10n.rightSide,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withAlpha(230),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: activeSide == null
                          ? () => startFeeding(FeedingSide.left)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 145,
                        decoration: BoxDecoration(
                          color: activeSide == FeedingSide.left
                              ? Colors.pink.withAlpha(38)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: activeSide == FeedingSide.left
                                ? Colors.pink
                                : Theme.of(context).dividerColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.pink,
                              size: 34,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.leftSide,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${controller.currentSession?.leftDuration.inMinutes ?? 0}m",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (activeSide == FeedingSide.left)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.pink,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    l10n.live,
                                    style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: activeSide == null
                          ? () => startFeeding(FeedingSide.right)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 145,
                        decoration: BoxDecoration(
                          color: activeSide == FeedingSide.right
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(38)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: activeSide == FeedingSide.right
                                ? const Color(0xff4DA3FF)
                                : Theme.of(context).dividerColor,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Color(0xff4DA3FF),
                              size: 34,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.rightSide,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${controller.currentSession?.rightDuration.inMinutes ?? 0}m",
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (activeSide == FeedingSide.right)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff4DA3FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "LIVE",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (activeSide != null)
                ElevatedButton(
                  onPressed: stopFeeding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.stop,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              if (entries.isNotEmpty && activeSide == null) ...[
                Text(
                  l10n.feedingAfterWeight,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: endWeightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: l10n.exampleWeight,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: finishSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.save,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              if (entries.isNotEmpty) buildSimpleSummary(entries),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSimpleSummary(List<FeedingEntry> entries) {
    final l10n = AppLocalizations.of(context);
    Duration left = Duration.zero;
    Duration right = Duration.zero;

    for (final entry in entries) {
      if (entry.side == FeedingSide.left) {
        left += entry.duration;
      } else {
        right += entry.duration;
      }
    }

    final total = left + right;
    final leftPct =
        total.inSeconds == 0 ? 0.5 : left.inSeconds / total.inSeconds;
    final rightPct =
        total.inSeconds == 0 ? 0.5 : right.inSeconds / total.inSeconds;

    String fmt(Duration duration) =>
        "${duration.inMinutes.toString().padLeft(2, '0')}:"
        "${(duration.inSeconds % 60).toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.feedingSummary,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Expanded(
                  flex: (leftPct * 1000).toInt(),
                  child: Container(height: 12, color: Colors.pink),
                ),
                Expanded(
                  flex: (rightPct * 1000).toInt(),
                  child: Container(height: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.leftLabel,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.pink,
                    ),
                  ),
                  Text(
                    "${(leftPct * 100).toStringAsFixed(0)}%",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  Text(
                    fmt(left),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.rightLabel,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    "${(rightPct * 100).toStringAsFixed(0)}%",
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  Text(
                    fmt(right),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              "${l10n.totalLabel}: ${fmt(total)}",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ManualFeedingModal extends StatefulWidget {
  final Function(FeedingSession) onSave;

  const ManualFeedingModal({super.key, required this.onSave});

  @override
  State<ManualFeedingModal> createState() => _ManualFeedingModalState();
}

class _ManualFeedingModalState extends State<ManualFeedingModal> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  double leftRatio = 0.5;
  Duration totalDuration = Duration.zero;
  Duration leftDuration = Duration.zero;
  Duration rightDuration = Duration.zero;

  void _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        startTime = picked;
        _recalculate();
      });
    }
  }

  void _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        endTime = picked;
        _recalculate();
      });
    }
  }

  void _recalculate() {
    if (startTime == null || endTime == null) return;

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
      startTime!.hour,
      startTime!.minute,
    );
    final end = DateTime(
      now.year,
      now.month,
      now.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (end.isBefore(start)) return;

    totalDuration = end.difference(start);
    leftDuration = Duration(
      seconds: (totalDuration.inSeconds * leftRatio).round(),
    );
    rightDuration = totalDuration - leftDuration;
  }

  void _save() {
    if (startTime == null || endTime == null) return;

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
      startTime!.hour,
      startTime!.minute,
    );
    final end = DateTime(
      now.year,
      now.month,
      now.day,
      endTime!.hour,
      endTime!.minute,
    );

    final session = FeedingSession(
      startTime: start,
      endTime: end,
      entries: [
        FeedingEntry(side: FeedingSide.left, duration: leftDuration),
        FeedingEntry(side: FeedingSide.right, duration: rightDuration),
      ],
      startWeightGr: null,
      endWeightGr: null,
      milkIntakeGr: null,
    );

    widget.onSave(session);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.manualFeedingEntry,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.startTime),
              TextButton(
                onPressed: _pickStart,
                child: Text(
                  startTime == null
                      ? l10n.select
                      : "${startTime!.hour.toString().padLeft(2, '0')}:"
                          "${startTime!.minute.toString().padLeft(2, '0')}",
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.endTime),
              TextButton(
                onPressed: _pickEnd,
                child: Text(
                  endTime == null
                      ? l10n.select
                      : "${endTime!.hour.toString().padLeft(2, '0')}:"
                          "${endTime!.minute.toString().padLeft(2, '0')}",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(l10n.leftRightRatio),
          Slider(
            value: leftRatio,
            onChanged: (value) {
              setState(() {
                leftRatio = value;
                _recalculate();
              });
            },
          ),
          Text(
            "${(leftRatio * 100).toStringAsFixed(0)}% Left - "
            "${(100 - leftRatio * 100).toStringAsFixed(0)}% Right",
          ),
          const SizedBox(height: 20),
          if (totalDuration.inSeconds > 0) ...[
            Text("Total: ${totalDuration.inMinutes} min"),
            Text("Left: ${leftDuration.inMinutes} min"),
            Text("Right: ${rightDuration.inMinutes} min"),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              l10n.save,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
