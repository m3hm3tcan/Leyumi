import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/child/active_child_app_bar_title.dart';
import '../../l10n/app_localizations.dart';
import '../../services/baby_storage.dart';
import '../../services/feeding_storage.dart';
import 'feeding_controller.dart';
import 'feeding_draft_service.dart';
import 'feeding_entry.dart';
import 'feeding_session.dart';
import 'sheets/manual_feeding_sheet.dart';
import 'widgets/feeding_save_dialog.dart';
import 'widgets/feeding_side_selector.dart';
import 'widgets/feeding_summary_card.dart';
import 'widgets/feeding_timer_card.dart';
import 'widgets/feeding_weight_field.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen>
    with WidgetsBindingObserver {
  late final FeedingController _controller;
  final FeedingStorage _storage = FeedingStorage();
  final FeedingDraftService _draftService = FeedingDraftService();
  final TextEditingController _startWeightController = TextEditingController();
  final TextEditingController _endWeightController = TextEditingController();
  final FocusNode _startWeightFocus = FocusNode();
  final FocusNode _endWeightFocus = FocusNode();

  Duration _currentTimer = Duration.zero;
  FeedingSide? _activeSide;
  String? _startWeightError;
  String? _endWeightError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = FeedingController(
      onTick: (duration) {
        if (mounted) setState(() => _currentTimer = duration);
      },
    );
    _restoreDraft();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _startWeightController.dispose();
    _endWeightController.dispose();
    _startWeightFocus.dispose();
    _endWeightFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _draftService.persist(_controller);
    }
  }

  Future<void> _restoreDraft() async {
    final draft = await _draftService.restore(_controller);
    if (draft == null || !mounted) return;

    _startWeightController.text = draft.startWeightGr?.toString() ?? '';
    _endWeightController.text = draft.endWeightGr?.toString() ?? '';
    setState(() {
      _activeSide = draft.activeSide;
      _currentTimer = draft.activeSideStartedAt == null
          ? Duration.zero
          : DateTime.now().difference(draft.activeSideStartedAt!);
    });
  }

  Future<bool> _handleBackPress() async {
    await _draftService.persist(_controller);
    if (!mounted) return true;

    if (_controller.currentSession != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).backLiveSession),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return true;
  }

  Future<void> _openManualAddSheet() async {
    final session = await showModalBottomSheet<FeedingSession>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ManualFeedingSheet(),
    );
    if (session == null) return;
    await _storage.saveSession(session);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _startFeeding(FeedingSide side) async {
    final startWeight = _validatedWeight(_startWeightController, isStart: true);
    if (_startWeightController.text.trim().isNotEmpty && startWeight == null) {
      _startWeightFocus.requestFocus();
      return;
    }
    if (_controller.currentSession == null) {
      _controller.setChildId((await BabyStorage().loadProfile())?.id);
      _controller.setStartWeight(startWeight);
    }

    setState(() {
      _activeSide = side;
      _currentTimer = Duration.zero;
    });
    _controller.startSide(side);
    await _draftService.persist(_controller);
  }

  Future<void> _stopFeeding() async {
    if (_activeSide == null) return;
    _controller.stopSide(_activeSide!);
    setState(() {
      _activeSide = null;
      _currentTimer = Duration.zero;
    });
    await _draftService.persist(_controller);
  }

  Future<void> _finishSession() async {
    final endWeight = _validatedWeight(_endWeightController, isStart: false);
    if (_endWeightController.text.trim().isNotEmpty && endWeight == null) {
      _endWeightFocus.requestFocus();
      return;
    }

    final decision = await showFeedingSaveDialog(context);
    if (!mounted || decision == null) return;

    if (decision == FeedingSaveDecision.discard) {
      await _draftService.clear();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    _controller.setEndWeight(endWeight);
    final session = _controller.finishSession();
    await _storage.saveSession(session);
    await _draftService.clear();
    if (mounted) Navigator.pop(context);
  }

  int? _validatedWeight(
    TextEditingController textController, {
    required bool isStart,
  }) {
    final raw = textController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        if (isStart) {
          _startWeightError = null;
        } else {
          _endWeightError = null;
        }
      });
      return null;
    }

    final value = int.tryParse(raw);
    final valid = value != null && value >= 500 && value <= 30000;
    setState(() {
      final error = valid
          ? null
          : AppLocalizations.of(context).weightRangeError;
      if (isStart) {
        _startWeightError = error;
      } else {
        _endWeightError = error;
      }
    });
    return valid ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = _controller.currentSession;
    final entries = session?.entries ?? [];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _handleBackPress() && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: ActiveChildAppBarTitle(title: l10n.feedingSessionTitle),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _openManualAddSheet,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              if (session == null) ...[
                FeedingWeightField(
                  controller: _startWeightController,
                  label: l10n.babyWeightGr,
                  focusNode: _startWeightFocus,
                  errorText: _startWeightError,
                  onChanged: (_) {
                    if (_startWeightError != null) {
                      setState(() => _startWeightError = null);
                    }
                  },
                ),
                const SizedBox(height: 14),
              ],
              FeedingTimerCard(elapsed: _currentTimer, activeSide: _activeSide),
              const SizedBox(height: 16),
              FeedingSideSelector(
                activeSide: _activeSide,
                leftDuration: session?.leftDuration ?? Duration.zero,
                rightDuration: session?.rightDuration ?? Duration.zero,
                onSelected: _startFeeding,
              ),
              const SizedBox(height: 14),
              if (_activeSide != null) _stopButton(l10n),
              const SizedBox(height: 20),
              if (entries.isNotEmpty && _activeSide == null)
                _finishSection(l10n),
              const SizedBox(height: 20),
              if (entries.isNotEmpty) FeedingSummaryCard(entries: entries),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stopButton(AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: _stopFeeding,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        l10n.stop,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _finishSection(AppLocalizations l10n) {
    return Column(
      children: [
        FeedingWeightField(
          controller: _endWeightController,
          label: l10n.feedingAfterWeight,
          focusNode: _endWeightFocus,
          errorText: _endWeightError,
          onChanged: (_) {
            if (_endWeightError != null) {
              setState(() => _endWeightError = null);
            }
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _finishSession,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
    );
  }
}
