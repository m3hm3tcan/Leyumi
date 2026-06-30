import 'package:flutter/material.dart';

class HistoryPageShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget child;
  final bool showHeader;

  const HistoryPageShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.child,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xff111827), Color(0xff0B1120)]
                : [color.withAlpha(18), theme.scaffoldBackgroundColor],
          ),
        ),
        child: Column(
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: _PageHero(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                  color: color,
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class HistoryEmptyState extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const HistoryEmptyState({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
          decoration: BoxDecoration(
            color: theme.cardColor.withAlpha(isDark ? 210 : 245),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withAlpha(isDark ? 45 : 26)),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(isDark ? 35 : 24),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withAlpha(45), color.withAlpha(18)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 42, color: color),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  height: 1.45,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HistorySectionTitle extends StatelessWidget {
  final String title;
  final int? count;
  final Color color;
  final String? countLabel;

  const HistorySectionTitle({
    super.key,
    required this.title,
    required this.color,
    this.count,
    this.countLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color?.withAlpha(170) ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: secondaryTextColor,
              decoration: TextDecoration.none,
            ),
          ),
          if (count != null && countLabel != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha(24),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '$count $countLabel',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PageHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _PageHero({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor.withAlpha(isDark ? 215 : 245),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withAlpha(isDark ? 42 : 24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 36 : 11),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withAlpha(54), color.withAlpha(20)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.2,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        theme.textTheme.bodyMedium?.color?.withAlpha(165) ??
                        Colors.grey,
                    fontSize: 12,
                    height: 1.35,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
