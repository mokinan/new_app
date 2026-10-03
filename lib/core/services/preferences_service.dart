import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive user preferences (theme, language, onboarding).
///
/// Plain Dart: each branch exposes these values through its own state
/// management (GetX controller, Cubit, Notifier, ...). Reads are synchronous
/// because [SharedPreferences] is loaded once at startup.
class PreferencesService {
  PreferencesService(this._prefs);

  static const _kDarkMode = 'isDarkMode';
  static const _kLocale = 'locale';
  static const _kOnboarded = 'isOnboarded';

  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async => PreferencesService(await SharedPreferences.getInstance());

  bool get isDarkMode => _prefs.getBool(_kDarkMode) ?? false;
  String get locale => _prefs.getString(_kLocale) ?? 'ar';
  bool get isOnboarded => _prefs.getBool(_kOnboarded) ?? false;

  Future<void> setDarkMode({required bool value}) => _prefs.setBool(_kDarkMode, value);
  Future<void> setLocale(String languageCode) => _prefs.setString(_kLocale, languageCode);
  Future<void> setOnboarded({required bool value}) => _prefs.setBool(_kOnboarded, value);
}
