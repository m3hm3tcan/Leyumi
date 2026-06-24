import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../shared/widgets/premium_badge.dart';

class HomeActionCard extends StatefulWidget {
  const HomeActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.colors,
    this.isPremium = false,
    this.isWide = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPremium;
  final bool isWide;
  final List<Color> colors;

  @override
  State<HomeActionCard> createState() => _HomeActionCardState();
}

class _HomeActionCardState extends State<HomeActionCard> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = .96),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: AppDurations.quick,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: widget.isWide ? _wideContent() : _compactContent(),
        ),
      ),
    );
  }

  Widget _icon() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(36)),
      ),
      child: Icon(widget.icon, color: Colors.white, size: 22),
    );
  }

  Widget _compactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _icon(),
            const Spacer(),
            if (widget.isPremium) const PremiumBadge(compact: true),
          ],
        ),
        const Spacer(),
        _title(fontSize: 15),
        const SizedBox(height: 2),
        _subtitle(fontSize: 10.5),
      ],
    );
  }

  Widget _wideContent() {
    return Row(
      children: [
        _icon(),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(fontSize: 16),
              const SizedBox(height: 2),
              _subtitle(fontSize: 11),
            ],
          ),
        ),
        if (widget.isPremium) ...[
          const PremiumBadge(compact: true),
          const SizedBox(width: 8),
        ],
        const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white70,
          size: 15,
        ),
      ],
    );
  }

  Widget _title({required double fontSize}) {
    return Text(
      widget.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: fontSize,
      ),
    );
  }

  Widget _subtitle({required double fontSize}) {
    return Text(
      widget.subtitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.white.withAlpha(214), fontSize: fontSize),
    );
  }
}
