import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/growth/growth_update_screen.dart';
import 'features/diaper/diaper_add_screen.dart';
import 'l10n/app_localizations.dart';
import 'core/premium/premium_provider.dart';
import 'core/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
      ],
      child: const LeyumiApp(),
    ),
  );
}

class LeyumiApp extends StatelessWidget {
  const LeyumiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Leyumi - Growing with your little light. 🌙✨",

          /// 🌍 LOCALIZATION
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('tr'),
            Locale('hu'),
          ],

          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return supportedLocales.first;
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode ==
                  locale.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },

          /// 🌙 DARK MODE SYSTEM
          themeMode: themeProvider.themeMode,

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xffF6F7FB),

            cardColor: Colors.white,

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,

            scaffoldBackgroundColor: const Color(0xff121212),
            cardColor: const Color(0xff1E1E1E),

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xff1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),

          /// ROUTES
          initialRoute: "/home",
          routes: {
            "/onboarding": (_) => const OnboardingScreen(),
            "/home": (_) => const HomeScreen(),
            "/growth_update": (_) => const GrowthUpdateScreen(),
            "/diaper": (_) => const DiaperAddScreen(),
          },
        );
      },
    );
  }
}
