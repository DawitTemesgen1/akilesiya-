import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the application's current language (locale).
///
/// Widgets can listen to this provider to rebuild when the language changes.
/// The MaterialApp.router listens to this to switch the entire app's language.
class LanguageProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _currentLocale = const Locale('am');

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLocale();
  }

  /// Loads the saved locale from SharedPreferences.
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);
      if (savedLocale != null && (savedLocale == 'am' || savedLocale == 'en')) {
        _currentLocale = Locale(savedLocale);
        notifyListeners();
      }
    } catch (e) {
      // If loading fails, use default (Amharic)
      _currentLocale = const Locale('am');
    }
  }

  /// Sets the locale and saves it to SharedPreferences.
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;
    
    _currentLocale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // If saving fails, continue with the change anyway
      debugPrint('Failed to save locale: $e');
    }
  }

  /// Toggles the language between English ('en') and Amharic ('am').
  Future<void> toggleLocale() async {
    if (_currentLocale.languageCode == 'am') {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('am'));
    }
  }
}
