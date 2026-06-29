import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/growth/growth_update_screen.dart';
import 'features/diaper/diaper_add_screen.dart';
import 'features/settings/settings_screen.dart';
import 'l10n/app_localizations.dart';
import 'core/premium/premium_provider.dart';
import 'core/theme_provider.dart';
import 'core/theme/app_design_tokens.dart';
import 'core/child/active_child_provider.dart';
import 'services/care_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CareNotificationService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PremiumProvider()),
        ChangeNotifierProvider(create: (_) => ActiveChildProvider()),
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return supportedLocales.first;
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },

          /// 🌙 DARK MODE SYSTEM
          themeMode: themeProvider.themeMode,

          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xffF6F7FB),
            cardColor: Colors.white,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xff121212),
            cardColor: const Color(0xff1E1E1E),
            useMaterial3: true,
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
            "/settings": (_) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
