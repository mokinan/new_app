import 'package:flutter/material.dart';
import 'package:new_app/app/safe_change_notifier.dart';
import 'package:new_app/core/services/preferences_service.dart';

/// Theme and language, persisted through [PreferencesService].
class SettingsNotifier extends SafeChangeNotifier {
  SettingsNotifier(this._prefs) : _isDarkMode = _prefs.isDarkMode, _locale = Locale(_prefs.locale);

  final PreferencesService _prefs;

  bool _isDarkMode;
  Locale _locale;

  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _prefs.setDarkMode(value: _isDarkMode);
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();
    await _prefs.setLocale(languageCode);
  }

  Future<void> completeOnboarding() => _prefs.setOnboarded(value: true);
}
