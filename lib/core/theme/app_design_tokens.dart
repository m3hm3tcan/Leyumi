import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xff6558E8);
  static const secondary = Color(0xffA45DE7);
  static const success = Color(0xff38B89B);
  static const danger = Color(0xffE05273);
  static const warning = Color(0xffF3A83B);
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const section = 32.0;
}

abstract final class AppRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
  static const sheet = 28.0;
}

abstract final class AppDurations {
  static const quick = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 180);
  static const entrance = Duration(milliseconds: 600);
}

abstract final class AppShadows {
  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withAlpha(isDark ? 38 : 13),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }
}
