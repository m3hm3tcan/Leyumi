import 'dart:math' as math;

import 'package:flutter/material.dart';

class MilkBottlePainter extends CustomPainter {
  MilkBottlePainter({required this.fillRatio});

  final double fillRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = const Color(0xffBBB7D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final cap = Paint()..color = const Color(0xff756CE8);
    final milk = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xffFFFEF2), Color(0xffF4EBCB)],
      ).createShader(Offset.zero & size);

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 23, size.width - 16, size.height - 29),
      const Radius.circular(15),
    );
    final neck = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 11, size.width - 40, 20),
      const Radius.circular(6),
    );
    final capRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(17, 2, size.width - 34, 14),
      const Radius.circular(5),
    );

    canvas
      ..drawRRect(capRect, cap)
      ..drawRRect(neck, outline)
      ..drawRRect(body, outline);

    final inner = body.deflate(4);
    final milkHeight = inner.height * fillRatio;
    final milkRect = Rect.fromLTWH(
      inner.left,
      inner.bottom - milkHeight,
      inner.width,
      milkHeight,
    );

    canvas
      ..save()
      ..clipRRect(inner)
      ..drawRect(milkRect, milk);

    if (milkHeight > 2) {
      final wave = Path()..moveTo(inner.left, milkRect.top + 2);
      for (double x = inner.left; x <= inner.right; x += 2) {
        wave.lineTo(x, milkRect.top + math.sin(x / 6) * 1.8);
      }
      wave
        ..lineTo(inner.right, milkRect.top + 5)
        ..lineTo(inner.left, milkRect.top + 5)
        ..close();
      canvas.drawPath(wave, milk);
    }
    canvas.restore();

    final marker = Paint()
      ..color = const Color(0xffBBB7D8).withAlpha(130)
      ..strokeWidth = 1;
    for (var index = 1; index < 5; index++) {
      final y = inner.bottom - inner.height * index / 5;
      canvas.drawLine(
        Offset(inner.right - 10, y),
        Offset(inner.right, y),
        marker,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MilkBottlePainter oldDelegate) =>
      oldDelegate.fillRatio != fillRatio;
}
