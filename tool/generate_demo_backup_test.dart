import 'package:flutter_test/flutter_test.dart';

import 'generate_demo_backup.dart' as generator;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generates the encrypted 14-day demo backup', () async {
    await generator.main();
  });
}
