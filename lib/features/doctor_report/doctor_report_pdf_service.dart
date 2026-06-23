import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/diaper/diaper_entry.dart';
import '../../features/feeding/feeding_session.dart';
import '../../l10n/app_localizations.dart';
import '../../models/baby_profile.dart';
import '../../models/growth_entry.dart';

class DoctorReportData {
  const DoctorReportData({
    required this.profile,
    required this.startDate,
    required this.endDate,
    required this.feedings,
    required this.diapers,
    required this.growthEntries,
  });

  final BabyProfile? profile;
  final DateTime startDate;
  final DateTime endDate;
  final List<FeedingSession> feedings;
  final List<DiaperEntry> diapers;
  final List<GrowthEntry> growthEntries;
}

class DoctorReportPdfService {
  const DoctorReportPdfService();

  Future<Uint8List> build({
    required DoctorReportData data,
    required AppLocalizations l10n,
  }) async {
    final regularData = await rootBundle.load('assets/fonts/Lato-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Lato-Bold.ttf');
    final regular = pw.Font.ttf(regularData);
    final bold = pw.Font.ttf(boldData);
    final document = pw.Document(
      title: l10n.doctorReport,
      author: 'Leyumi',
      creator: 'Leyumi',
    );

    final sortedGrowth = [...data.growthEntries]
      ..sort((a, b) => a.date.compareTo(b.date));
    final totalFeedingMinutes = data.feedings.fold<int>(
      0,
      (sum, session) => sum + session.totalDuration.inMinutes,
    );
    final totalMilk = data.feedings.fold<int>(
      0,
      (sum, session) => sum + session.totalMilkIntake,
    );
    final leftMinutes = data.feedings.fold<int>(
      0,
      (sum, session) => sum + session.leftDuration.inMinutes,
    );
    final rightMinutes = data.feedings.fold<int>(
      0,
      (sum, session) => sum + session.rightDuration.inMinutes,
    );
    final wetCount = data.diapers
        .where((entry) => entry.type == DiaperType.pee)
        .length;
    final dirtyCount = data.diapers
        .where((entry) => entry.type == DiaperType.poop)
        .length;
    final bothCount = data.diapers
        .where((entry) => entry.type == DiaperType.both)
        .length;

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(34, 34, 34, 30),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        header: (context) => _header(context, l10n),
        footer: (context) => _footer(context, l10n),
        build: (context) => [
          pw.SizedBox(height: 12),
          pw.Text(
            l10n.doctorReport,
            style: pw.TextStyle(
              font: bold,
              fontSize: 25,
              color: PdfColor.fromHex('#382F73'),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${l10n.reportPeriod}: ${_date(data.startDate)} - ${_date(data.endDate)}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 18),
          _babyInformation(data.profile, l10n, bold),
          pw.SizedBox(height: 18),
          _sectionTitle(l10n.reportSummary, bold),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              _metric(
                l10n.feeding,
                '${data.feedings.length}',
                l10n.sessions,
                PdfColor.fromHex('#EC668B'),
                bold,
              ),
              pw.SizedBox(width: 8),
              _metric(
                l10n.totalFeedingTime,
                '$totalFeedingMinutes',
                l10n.minutesShort,
                PdfColor.fromHex('#5D8DF6'),
                bold,
              ),
              pw.SizedBox(width: 8),
              _metric(
                l10n.diaper,
                '${data.diapers.length}',
                l10n.diaperChanges,
                PdfColor.fromHex('#3CB8A0'),
                bold,
              ),
              pw.SizedBox(width: 8),
              _metric(
                l10n.milkIntake,
                '$totalMilk',
                l10n.unitGr,
                PdfColor.fromHex('#A16CE0'),
                bold,
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(l10n.feedingSummary, bold),
          pw.SizedBox(height: 8),
          _keyValueTable(
            [
              [l10n.sessions, '${data.feedings.length}'],
              [l10n.totalFeedingTime, '$totalFeedingMinutes ${l10n.minutesShort}'],
              [
                l10n.average,
                data.feedings.isEmpty
                    ? '0 ${l10n.minutesShort}'
                    : '${(totalFeedingMinutes / data.feedings.length).round()} ${l10n.minutesShort}',
              ],
              [l10n.leftBreast, '$leftMinutes ${l10n.minutesShort}'],
              [l10n.rightBreast, '$rightMinutes ${l10n.minutesShort}'],
              [l10n.milkIntake, '$totalMilk ${l10n.unitGr}'],
            ],
            bold,
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(l10n.diaperSummary, bold),
          pw.SizedBox(height: 8),
          _keyValueTable(
            [
              [l10n.totalLabel, '${data.diapers.length}'],
              [l10n.pee, '$wetCount'],
              [l10n.poop, '$dirtyCount'],
              [l10n.peeAndPoop, '$bothCount'],
            ],
            bold,
          ),
          pw.SizedBox(height: 18),
          _sectionTitle(l10n.growthSummary, bold),
          pw.SizedBox(height: 8),
          if (sortedGrowth.isEmpty)
            _emptyState(l10n.noGrowthData)
          else
            _growthSummary(sortedGrowth, l10n, bold),
          pw.SizedBox(height: 18),
          _sectionTitle(l10n.dailyActivitySummary, bold),
          pw.SizedBox(height: 8),
          _dailyTable(data, l10n, bold),
          if (sortedGrowth.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            _sectionTitle(l10n.growthMeasurements, bold),
            pw.SizedBox(height: 8),
            _growthTable(sortedGrowth, l10n, bold),
          ],
          pw.SizedBox(height: 18),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F4F1FC'),
              borderRadius: pw.BorderRadius.circular(7),
            ),
            child: pw.Text(
              l10n.reportMedicalDisclaimer,
              style: const pw.TextStyle(
                fontSize: 8.5,
                lineSpacing: 2,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _header(pw.Context context, AppLocalizations l10n) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'LEYUMI',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
            color: PdfColor.fromHex('#6B5CE7'),
            letterSpacing: 1.5,
          ),
        ),
        pw.Text(
          l10n.generatedOn(_date(DateTime.now())),
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _footer(pw.Context context, AppLocalizations l10n) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            l10n.generatedByLeyumi,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  pw.Widget _babyInformation(
    BabyProfile? profile,
    AppLocalizations l10n,
    pw.Font bold,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8F7FD'),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromHex('#E8E4F6')),
      ),
      child: profile == null
          ? pw.Text(l10n.noBabyProfile)
          : pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _infoItem(l10n.babyNameLabel, profile.name, bold),
                ),
                pw.Expanded(
                  child: _infoItem(
                    l10n.birthDate,
                    _date(profile.birthDate),
                    bold,
                  ),
                ),
                pw.Expanded(
                  child: _infoItem(
                    l10n.genderLabel,
                    profile.gender.toLowerCase() == 'male'
                        ? l10n.genderMale
                        : l10n.genderFemale,
                    bold,
                  ),
                ),
              ],
            ),
    );
  }

  pw.Widget _infoItem(String label, String value, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 3),
        pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 11)),
      ],
    );
  }

  pw.Widget _sectionTitle(String title, pw.Font bold) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        font: bold,
        fontSize: 14,
        color: PdfColor.fromHex('#332B66'),
      ),
    );
  }

  pw.Widget _metric(
    String label,
    String value,
    String unit,
    PdfColor color,
    pw.Font bold,
  ) {
    return pw.Expanded(
      child: pw.Container(
        height: 70,
        padding: const pw.EdgeInsets.all(9),
        decoration: pw.BoxDecoration(
          color: color.shade(.92),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              maxLines: 1,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  value,
                  style: pw.TextStyle(font: bold, fontSize: 18, color: color),
                ),
                pw.SizedBox(width: 3),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text(
                    unit,
                    style: const pw.TextStyle(
                      fontSize: 7,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _keyValueTable(List<List<String>> rows, pw.Font bold) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E7E5EE'), width: .6),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(1),
      },
      children: [
        for (var index = 0; index < rows.length; index++)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index.isEven ? PdfColor.fromHex('#FAFAFC') : PdfColors.white,
            ),
            children: [
              _cell(rows[index][0]),
              _cell(rows[index][1], font: bold, alignRight: true),
            ],
          ),
      ],
    );
  }

  pw.Widget _growthSummary(
    List<GrowthEntry> entries,
    AppLocalizations l10n,
    pw.Font bold,
  ) {
    final first = entries.first;
    final latest = entries.last;
    final weightChange = latest.weight - first.weight;
    final heightChange = latest.height - first.height;
    return _keyValueTable(
      [
        [l10n.latestMeasurement, _date(latest.date)],
        [l10n.weight, '${latest.weight} ${l10n.unitGr}'],
        [l10n.height, '${latest.height} ${l10n.unitCm}'],
        [
          l10n.weightChange,
          '${weightChange >= 0 ? '+' : ''}$weightChange ${l10n.unitGr}',
        ],
        [
          l10n.heightChange,
          '${heightChange >= 0 ? '+' : ''}$heightChange ${l10n.unitCm}',
        ],
      ],
      bold,
    );
  }

  pw.Widget _dailyTable(
    DoctorReportData data,
    AppLocalizations l10n,
    pw.Font bold,
  ) {
    final days = <DateTime>{};
    for (final feeding in data.feedings) {
      days.add(_day(feeding.startTime));
    }
    for (final diaper in data.diapers) {
      days.add(_day(diaper.timestamp));
    }
    final sortedDays = days.toList()..sort((a, b) => b.compareTo(a));
    if (sortedDays.isEmpty) return _emptyState(l10n.noDataForPeriod);

    final rows = sortedDays.map((day) {
      final feedings = data.feedings
          .where((item) => _day(item.startTime) == day)
          .toList();
      final diapers = data.diapers
          .where((item) => _day(item.timestamp) == day)
          .toList();
      final minutes = feedings.fold<int>(
        0,
        (sum, item) => sum + item.totalDuration.inMinutes,
      );
      return [
        _date(day),
        '${feedings.length}',
        '$minutes ${l10n.minutesShort}',
        '${diapers.length}',
      ];
    }).toList();

    return _dataTable(
      [l10n.dateAndTime, l10n.feeding, l10n.duration, l10n.diaper],
      rows,
      bold,
    );
  }

  pw.Widget _growthTable(
    List<GrowthEntry> entries,
    AppLocalizations l10n,
    pw.Font bold,
  ) {
    return _dataTable(
      [
        l10n.dateAndTime,
        l10n.weight,
        l10n.height,
        l10n.headCircumference,
      ],
      entries.reversed
          .map(
            (entry) => [
              _date(entry.date),
              '${entry.weight} ${l10n.unitGr}',
              '${entry.height} ${l10n.unitCm}',
              entry.headCircumference == null
                  ? '-'
                  : '${entry.headCircumference} ${l10n.unitCm}',
            ],
          )
          .toList(),
      bold,
    );
  }

  pw.Widget _dataTable(
    List<String> headers,
    List<List<String>> rows,
    pw.Font bold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#E7E5EE'), width: .6),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#ECE9F8')),
          children: headers
              .map((header) => _cell(header, font: bold))
              .toList(),
        ),
        for (var index = 0; index < rows.length; index++)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index.isEven ? PdfColors.white : PdfColor.fromHex('#FAFAFC'),
            ),
            children: rows[index].map(_cell).toList(),
          ),
      ],
    );
  }

  pw.Widget _cell(
    String value, {
    pw.Font? font,
    bool alignRight = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      child: pw.Text(
        value,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(font: font, fontSize: 8.5),
      ),
    );
  }

  pw.Widget _emptyState(String text) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      color: PdfColor.fromHex('#FAFAFC'),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
      ),
    );
  }

  DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.'
      '${value.month.toString().padLeft(2, '0')}.${value.year}';
}
