import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_app/core/services/preferences_service.dart';

class SettingsState extends Equatable {
  const SettingsState({required this.isDarkMode, required this.locale});

  final bool isDarkMode;
  final Locale locale;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsState copyWith({bool? isDarkMode, Locale? locale}) =>
      SettingsState(isDarkMode: isDarkMode ?? this.isDarkMode, locale: locale ?? this.locale);

  @override
  List<Object> get props => [isDarkMode, locale];
}

/// Theme and language, persisted through [PreferencesService].
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._prefs) : super(SettingsState(isDarkMode: _prefs.isDarkMode, locale: Locale(_prefs.locale)));

  final PreferencesService _prefs;

  Future<void> toggleDarkMode() async {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
    await _prefs.setDarkMode(value: state.isDarkMode);
  }

  Future<void> setLocale(String languageCode) async {
    emit(state.copyWith(locale: Locale(languageCode)));
    await _prefs.setLocale(languageCode);
  }

  Future<void> completeOnboarding() => _prefs.setOnboarded(value: true);
}
