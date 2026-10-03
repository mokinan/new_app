import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_app/core/services/preferences_service.dart';

/// Theme and language, persisted through [PreferencesService].
class SettingsController extends GetxController {
  SettingsController(this._prefs) : isDarkMode = _prefs.isDarkMode.obs, locale = Locale(_prefs.locale).obs;

  static SettingsController get to => Get.find();

  final PreferencesService _prefs;

  final RxBool isDarkMode;
  final Rx<Locale> locale;

  bool get isOnboarded => _prefs.isOnboarded;

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleDarkMode() async {
    isDarkMode.toggle();
    Get.changeThemeMode(themeMode);
    await _prefs.setDarkMode(value: isDarkMode.value);
  }

  Future<void> setLocale(String languageCode) async {
    locale.value = Locale(languageCode);
    await Get.updateLocale(locale.value);
    await _prefs.setLocale(languageCode);
  }

  Future<void> completeOnboarding() => _prefs.setOnboarded(value: true);
}
