import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/features/care_report/care_report_pdf_service.dart';
import 'package:leyumi/l10n/app_localizations_en.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('creates a care report PDF with bundled fonts', () async {
    final start = DateTime.utc(2026, 8, 1);
    final bytes = await const CareReportPdfService().build(
      data: CareReportData(
        profile: null,
        startDate: start,
        endDate: DateTime.utc(2026, 8, 20),
        feedings: const [],
        diapers: const [],
        growthEntries: const [],
      ),
      l10n: AppLocalizationsEn(),
    );

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
