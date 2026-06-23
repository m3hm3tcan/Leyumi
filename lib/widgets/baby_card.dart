import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/baby_profile.dart';
import 'package:leyumi/l10n/app_localizations.dart';

class BabyCard extends StatefulWidget {
  final BabyProfile profile;

  const BabyCard({super.key, required this.profile});

  @override
  State<BabyCard> createState() => _BabyCardState();
}

class _BabyCardState extends State<BabyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get isBoy => widget.profile.gender.toLowerCase() == "male";
  bool get isGirl => widget.profile.gender.toLowerCase() == "female";

  Color get primaryColor {
    if (isBoy) return const Color(0xff4DA3FF);
    if (isGirl) return const Color(0xffFF6B9D);
    return const Color(0xffA78BFA);
  }

  String calculateAge(BuildContext context, DateTime birthDate) {
    final t = AppLocalizations.of(context);

    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months -= 1;
      days += DateTime(now.year, now.month, 0).day;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    if (years > 0) {
      return "$years ${t.yearsShort} $months ${t.monthsShort}";
    } else {
      return "$months ${t.monthsShort} $days ${t.daysShort}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withOpacity(0.25)
              : Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          )
        ],
      ),
      child: Stack(
        children: [
          /// 🌈 LOTTIE BACKGROUND
          Positioned(
            right: 0,
            top: -10,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.85,
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: Lottie.asset(
                    isBoy
                        ? "assets/lottie/baby_boy_bg.json"
                        : "assets/lottie/baby_girl_bg.json",
                    repeat: true,
                  ),
                ),
              ),
            ),
          ),

          /// CONTENT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  /// NAME + AGE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.profile.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          calculateAge(context, widget.profile.birthDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// STATS
              Row(
                children: [
                  _stat(
                    context,
                    t.weight,
                    "${widget.profile.weight} ${t.unitGr}",
                  ),
                  _stat(
                    context,
                    t.height,
                    "${widget.profile.height} ${t.unitCm}",
                  ),
                                  ],
              ),
            ],
          ),
        ],
      ),
    );
  }
 
  Widget _stat(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context)
                .textTheme
                .bodySmall
                ?.color
                ?.withOpacity(0.6),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
