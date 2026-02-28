import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for managing app theme (light/dark mode)
/// Persists user preference across app sessions via SharedPreferences.
class ThemeController extends ChangeNotifier {
  static const String _themePrefKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeController() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_themePrefKey);
      if (stored == null) return;

      _themeMode = switch (stored) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => _themeMode,
      };
      notifyListeners();
    } catch (_) {
      // Gracefully fall back to default theme on storage failure
    }
  }

  Future<void> _persistThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = switch (_themeMode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      };
      await prefs.setString(_themePrefKey, value);
    } catch (_) {
      // Non-critical: preference will fall back to default next launch
    }
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _persistThemeMode();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _persistThemeMode();
    notifyListeners();
  }
}
