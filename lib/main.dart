import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/growth/growth_update_screen.dart';
import 'features/diaper/diaper_add_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const BabyFeedApp());
}

class BabyFeedApp extends StatelessWidget {
  const BabyFeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BabyFeed Pro",
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return supportedLocales.first;
        }
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      initialRoute: "/home",
      routes: {
        "/onboarding": (_) => const OnboardingScreen(),
        "/home": (_) => const HomeScreen(),
        "/growth_update": (_) => const GrowthUpdateScreen(),
        "/diaper": (_) => const DiaperAddScreen(),
        // "/growth_history": (_) => const GrowthHistoryScreen(),
      },
    );
  }
}
