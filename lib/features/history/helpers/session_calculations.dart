import 'package:leyumi/features/feeding/feeding_session.dart';

Duration calculateLeftTotal(FeedingSession session) {
  return session.entries
      .where((e) => e.side == "left")
      .fold(Duration.zero, (a, b) => a + b.duration);
}

Duration calculateRightTotal(FeedingSession session) {
  return session.entries
      .where((e) => e.side == "right")
      .fold(Duration.zero, (a, b) => a + b.duration);
}
