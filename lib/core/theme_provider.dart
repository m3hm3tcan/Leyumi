import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDark => themeMode == ThemeMode.dark;

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    themeMode =
        themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    await prefs.setBool("darkMode", themeMode == ThemeMode.dark);

    notifyListeners();
  }
}