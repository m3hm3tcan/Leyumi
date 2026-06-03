import 'package:flutter/material.dart';
import '../models/baby_profile.dart';

class BabyCard extends StatelessWidget {
  final BabyProfile profile;

  const BabyCard({super.key, required this.profile});

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
      return "$years yıl $months ay $days gün";
    } else {
      return "$months ay $days gün";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NAME + GENDER
          Row(
            children: [
              const Icon(Icons.child_care, size: 40, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                "${profile.name} (${profile.gender})",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // AGE
          Text(
            "Yaş: ${calculateAge(profile.birthDate)}",
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 8),

          // WEIGHT
          Text(
            "Kilo: ${profile.weight} gr",
            style: const TextStyle(fontSize: 16),
          ),

          // HEIGHT
          Text(
            "Boy: ${profile.height} cm",
            style: const TextStyle(fontSize: 16),
          ),

          // OPTIONAL FIELDS
          if (profile.headCircumference != null)
            Text(
              "Kafa çevresi: ${profile.headCircumference} cm",
              style: const TextStyle(fontSize: 16),
            ),

          if (profile.waistCircumference != null)
            Text(
              "Bel çevresi: ${profile.waistCircumference} cm",
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }
}
