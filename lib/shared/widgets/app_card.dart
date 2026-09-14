import 'package:flutter/material.dart';

import '../../core/theme/app_design_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.borderRadius = AppRadius.xl,
    this.color,
    this.border,
    this.shadows,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: shadows ?? AppShadows.card(context),
      ),
      child: child,
    );
  }
}
