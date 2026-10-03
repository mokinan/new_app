import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_app/app/providers.dart';

@immutable
class SettingsState {
  const SettingsState({required this.isDarkMode, required this.locale});

  final bool isDarkMode;
  final Locale locale;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsState copyWith({bool? isDarkMode, Locale? locale}) =>
      SettingsState(isDarkMode: isDarkMode ?? this.isDarkMode, locale: locale ?? this.locale);
}

/// Theme and language, persisted through `PreferencesService`.
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final prefs = ref.watch(preferencesServiceProvider);
    return SettingsState(isDarkMode: prefs.isDarkMode, locale: Locale(prefs.locale));
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    await ref.read(preferencesServiceProvider).setDarkMode(value: state.isDarkMode);
  }

  Future<void> setLocale(String languageCode) async {
    state = state.copyWith(locale: Locale(languageCode));
    await ref.read(preferencesServiceProvider).setLocale(languageCode);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
