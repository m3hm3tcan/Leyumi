import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../core/child/active_child_aware.dart';
import '../../core/child/active_child_app_bar_title.dart';
import '../../features/diaper/diaper_entry.dart';
import '../../features/feeding/feeding_session.dart';
import '../../l10n/app_localizations.dart';
import '../../models/baby_profile.dart';
import '../../models/growth_entry.dart';
import '../../services/baby_storage.dart';
import '../../services/diaper_storage.dart';
import '../../services/feeding_storage.dart';
import '../../services/growth_storage.dart';
import 'doctor_report_pdf_service.dart';

enum _ReportRange { sevenDays, thirtyDays, ninetyDays, all }

class DoctorReportScreen extends StatefulWidget {
  const DoctorReportScreen({super.key});

  @override
  State<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends State<DoctorReportScreen>
    with ActiveChildAware<DoctorReportScreen> {
  BabyProfile? _profile;
  List<FeedingSession> _feedings = [];
  List<DiaperEntry> _diapers = [];
  List<GrowthEntry> _growth = [];
  _ReportRange _range = _ReportRange.thirtyDays;
  bool _isLoading = true;
  bool _isGenerating = false;

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    final results = await Future.wait<dynamic>([
      BabyStorage().loadProfile(),
      FeedingStorage().loadSessions(),
      DiaperStorage().loadEntries(),
      GrowthStorage().loadEntries(),
    ]);
    if (!mounted) return;
    setState(() {
      _profile = results[0] as BabyProfile?;
      _feedings = results[1] as List<FeedingSession>;
      _diapers = results[2] as List<DiaperEntry>;
      _growth = results[3] as List<GrowthEntry>;
      _isLoading = false;
    });
  }

  @override
  Future<void> onActiveChildChanged() => _loadData();

  DateTime get _endDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  }

  DateTime get _startDate {
    final end = _endDate;
    switch (_range) {
      case _ReportRange.sevenDays:
        return DateTime(
          end.year,
          end.month,
          end.day,
        ).subtract(const Duration(days: 6));
      case _ReportRange.thirtyDays:
        return DateTime(
          end.year,
          end.month,
          end.day,
        ).subtract(const Duration(days: 29));
      case _ReportRange.ninetyDays:
        return DateTime(
          end.year,
          end.month,
          end.day,
        ).subtract(const Duration(days: 89));
      case _ReportRange.all:
        final dates = <DateTime>[
          ..._feedings.map((entry) => entry.startTime),
          ..._diapers.map((entry) => entry.timestamp),
          ..._growth.map((entry) => entry.date),
        ];
        if (dates.isEmpty) {
          return DateTime(
            end.year,
            end.month,
            end.day,
          ).subtract(const Duration(days: 29));
        }
        dates.sort();
        final first = dates.first;
        return DateTime(first.year, first.month, first.day);
    }
  }

  DoctorReportData get _reportData {
    final start = _startDate;
    final end = _endDate;
    bool inRange(DateTime value) =>
        !value.isBefore(start) && !value.isAfter(end);

    return DoctorReportData(
      profile: _profile,
      startDate: start,
      endDate: end,
      feedings: _feedings.where((item) => inRange(item.startTime)).toList(),
      diapers: _diapers.where((item) => inRange(item.timestamp)).toList(),
      growthEntries: _growth.where((item) => inRange(item.date)).toList(),
    );
  }

  Future<void> _createAndShareReport() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isGenerating = true);
    try {
      final data = _reportData;
      final bytes = await const DoctorReportPdfService().build(
        data: data,
        l10n: l10n,
      );
      final babyName = _profile?.name.trim().replaceAll(' ', '_');
      final normalizedName = babyName?.replaceAll(
        RegExp(r'[^a-zA-Z0-9_-]'),
        '',
      );
      final safeName = normalizedName == null || normalizedName.isEmpty
          ? 'baby'
          : normalizedName;
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'Leyumi_${safeName}_${_fileDate(data.startDate)}_${_fileDate(data.endDate)}.pdf',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reportGenerationFailed)));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  String _fileDate(DateTime value) =>
      '${value.year}${value.month.toString().padLeft(2, '0')}'
      '${value.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: ActiveChildAppBarTitle(title: l10n.doctorReport)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xff6259E8), Color(0xffA35FDD)],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff725DE2).withAlpha(55),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(35),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.doctorReport,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  l10n.doctorReportDescription,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(215),
                                    fontSize: 12.5,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.selectReportPeriod,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _rangeChip(_ReportRange.sevenDays, l10n.last7Days),
                        _rangeChip(_ReportRange.thirtyDays, l10n.last30Days),
                        _rangeChip(_ReportRange.ninetyDays, l10n.last90Days),
                        _rangeChip(_ReportRange.all, l10n.all),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _periodCard(l10n, theme),
                    const SizedBox(height: 16),
                    _reportContents(l10n, theme),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isGenerating ? null : _createAndShareReport,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.ios_share_rounded),
                        label: Text(
                          _isGenerating
                              ? l10n.preparingReport
                              : l10n.createAndSharePdf,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xff6558E8),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xff6558E8,
                          ).withAlpha(150),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.reportPrivacyNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(145),
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _rangeChip(_ReportRange value, String label) {
    final selected = _range == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _range = value),
      selectedColor: const Color(0xff6558E8),
      backgroundColor: Theme.of(context).cardColor,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected
            ? const Color(0xff6558E8)
            : Theme.of(context).dividerColor.withAlpha(70),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget _periodCard(AppLocalizations l10n, ThemeData theme) {
    final data = _reportData;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withAlpha(35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.date_range_rounded, color: Color(0xff6558E8)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_displayDate(data.startDate)} - ${_displayDate(data.endDate)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _miniMetric(
                l10n.feeding,
                '${data.feedings.length}',
                const Color(0xffEC668B),
              ),
              _miniMetric(
                l10n.diaper,
                '${data.diapers.length}',
                const Color(0xff3CB8A0),
              ),
              _miniMetric(
                l10n.growth,
                '${data.growthEntries.length}',
                const Color(0xff5D8DF6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _reportContents(AppLocalizations l10n, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withAlpha(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reportIncludes,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 13),
          _contentLine(Icons.child_care_rounded, l10n.babyInformation),
          _contentLine(Icons.local_drink_rounded, l10n.feedingSummary),
          _contentLine(Icons.baby_changing_station, l10n.diaperSummary),
          _contentLine(Icons.monitor_weight_rounded, l10n.growthSummary),
          _contentLine(
            Icons.calendar_view_week_rounded,
            l10n.dailyActivitySummary,
          ),
        ],
      ),
    );
  }

  Widget _contentLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff6558E8), size: 19),
          const SizedBox(width: 11),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xff38B89B),
            size: 18,
          ),
        ],
      ),
    );
  }

  String _displayDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.'
      '${value.month.toString().padLeft(2, '0')}.${value.year}';
}
