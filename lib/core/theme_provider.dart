import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode themeMode = ThemeMode.system;

  bool get isDark => themeMode == ThemeMode.dark;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDarkMode = prefs.getBool("darkMode");

    if (savedDarkMode == null) return;

    themeMode = savedDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    await prefs.setBool("darkMode", themeMode == ThemeMode.dark);

    notifyListeners();
  }
}
