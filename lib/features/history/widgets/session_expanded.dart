import 'package:flutter/material.dart';
import 'package:babyfeedpro/features/feeding/feeding_session.dart';
import '../helpers/history_formatters.dart';

class SessionExpanded extends StatelessWidget {
  final FeedingSession session;
  final Duration leftTotal;
  final Duration rightTotal;

  const SessionExpanded({
    super.key,
    required this.session,
    required this.leftTotal,
    required this.rightTotal,
  });

  @override
  Widget build(BuildContext context) {
    final startW = session.startWeightGr;
    final endW = session.endWeightGr;
    final diff = session.milkIntakeGr;

    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sol meme: ${leftTotal.inMinutes}m",
            style: TextStyle(color: Colors.pink.shade400),
          ),
          Text(
            "Sağ meme: ${rightTotal.inMinutes}m",
            style: TextStyle(color: Colors.blue.shade400),
          ),

          const SizedBox(height: 14),

          if (startW != null && endW != null) ...[
            const Divider(),
            Text("İlk kilo: $startW gr"),
            Text("Son kilo: $endW gr"),
            const SizedBox(height: 8),
          ],

          if ((diff ?? 0) > 0)
            Text(
              "İçilen süt: $diff gr",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}