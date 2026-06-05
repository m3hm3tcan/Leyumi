import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/baby_profile.dart';

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

  String calculateAge(DateTime birthDate) {
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
      return "$years y $months m";
    } else {
      return "$months m $days d";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  width: 90,
                  height: 90,
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
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          calculateAge(widget.profile.birthDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 👦👧 ICON BADGE
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBoy ? Icons.male : Icons.female,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// STATS
              Row(
                children: [
                  _stat("Weight", "${widget.profile.weight} g"),
                  _stat("Height", "${widget.profile.height} cm"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
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