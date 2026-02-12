import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the application's theme mode (light/dark/system).
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark theme

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Loads the saved theme mode from SharedPreferences.
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeModeKey);
      if (savedMode != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedMode,
          orElse: () => ThemeMode.dark,
        );
        // Don't call notifyListeners here to avoid triggering rebuilds during init
      }
    } catch (e) {
      // If loading fails, use dark default
      _themeMode = ThemeMode.dark;
    }
  }

  /// Sets the theme mode and saves it to SharedPreferences.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString());
    } catch (e) {
      // If saving fails, continue with the change anyway
      debugPrint('Failed to save theme mode: $e');
    }
  }

  /// Toggles between light and dark mode (skips system).
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Checks if dark mode is currently active.
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // Dark Theme Colors (existing design)
  static const Color darkBackground = Color(0xFF050511);
  static const Color darkSurface = Color(0xFF151522);
  static const Color darkPrimary = Color(0xFFFFC107); // Gold
  static const Color darkOnSurface = Colors.white;
  static const Color darkSubtle = Colors.white54;

  // Light Theme Colors (attendance summary style)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightPrimary = Color(0xFF1E3A8A); // Deep Blue
  static const Color lightAccent = Color(0xFFFFD700); // Gold accent
  static const Color lightOnSurface = Color(0xFF1E293B);
  static const Color lightSubtle = Color(0xFF64748B);

  // Common colors (same for both themes)
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFFD7E14);
  static const Color dangerColor = Color(0xFFDC3545);
  static const Color permissionColor = Color(0xFF0D6EFD);

  // Getters for current theme colors
  Color getBackgroundColor(BuildContext context) =>
      isDarkMode(context) ? darkBackground : lightBackground;

  Color getSurfaceColor(BuildContext context) =>
      isDarkMode(context) ? darkSurface : lightSurface;

  Color getPrimaryColor(BuildContext context) =>
      isDarkMode(context) ? darkPrimary : lightPrimary;

  Color getAccentColor(BuildContext context) =>
      isDarkMode(context) ? darkPrimary : lightAccent;

  Color getOnSurfaceColor(BuildContext context) =>
      isDarkMode(context) ? darkOnSurface : lightOnSurface;

  Color getSubtleTextColor(BuildContext context) =>
      isDarkMode(context) ? darkSubtle : lightSubtle;
}
