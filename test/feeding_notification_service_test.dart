import 'package:flutter_test/flutter_test.dart';
import 'package:leyumi/services/feeding_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'platform notification failures do not escape into record flows',
    () async {
      await expectLater(
        FeedingNotificationService.instance.showActiveFeeding(
          title: 'Feeding',
          body: 'Active',
          startedAt: DateTime.utc(2026, 8, 20),
        ),
        completes,
      );
      await expectLater(
        FeedingNotificationService.instance.cancelActiveFeeding(),
        completes,
      );
    },
  );
}
